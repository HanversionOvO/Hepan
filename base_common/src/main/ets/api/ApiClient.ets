import http from '@ohos.net.http';
import { Document, parseDocument } from '@ohos/htmlparser2';
import { LogUtil } from '@pura/harmony-utils';
import { CommonConstant } from '../constants/CommonConstant';
import { LegacyUtil } from '../utils/LegacyUtil';
import { AppPreferenceKeys, PreferenceUtil } from '../utils/PreferenceUtil';
import { RouterMap, RouterUtil } from '../utils/RouterUtil';
import { StorageManager } from '../utils/StorageManager';
import { ToastUtil } from '../utils/ToastUtil';
import { UrlUtil } from '../utils/UrlUtil';

const TAG = '[ApiClient]: ';

type ReLoginHandler = () => Promise<boolean>;

export interface ApiRequestOptions<T = Object> {
  path: string;
  method?: http.RequestMethod;
  headers?: Record<string, string>;
  data?: T;
  expectJson?: boolean;
  includeAuthorization?: boolean; // 默认为 true
  includeCookie?: boolean;
  requireNewApiHeader?: boolean;
}

export interface ApiResponse<T = Object> {
  status: number;
  data: T;
  headers: Record<string, string | string[]>;
  cookies: string[];
  raw: http.HttpResponse;
}

/**
 * 统一的 HTTP 客户端，负责处理 Cookie、Authorization 以及常用默认头
 */
export class ApiClient {
  private static instance: ApiClient | null = null;
  private baseUrlValue: string = CommonConstant.BASE_URL;
  private readonly legacyBasePath: string = '/mobcent/app/web/index.php';
  private readonly USER_AGENT = CommonConstant.USER_AGENT;
  private readonly cookieJar: Map<string, string> = new Map();
  private authorization: string = '';
  private isRedirecting: boolean = false; // 防止并发跳转
  private reLoginHandler: ReLoginHandler | null = null;

  private constructor() {
    this.initBaseUrl();
  }

  public static getInstance(): ApiClient {
    if (!ApiClient.instance) {
      ApiClient.instance = new ApiClient();
    }
    return ApiClient.instance;
  }

  public setReloginHandler(handler: ReLoginHandler) {
    this.reLoginHandler = handler;
  }

  public setAuthorization(token: string): void {
    this.authorization = token || '';
  }

  public setBaseUrl(url: string): void {
    const normalized = this.normalizeBaseUrl(url);
    const finalUrl = normalized ? normalized : CommonConstant.BASE_URL;
    this.baseUrlValue = finalUrl;
    PreferenceUtil.write(AppPreferenceKeys.prefName, (pref) => {
      pref.putSync(AppPreferenceKeys.baseUrl, finalUrl);
    });
  }

  public setCookieString(cookieStr: string): void {
    if (!cookieStr) {
      this.cookieJar.clear();
      return;
    }
    const pairs = cookieStr.split(';');
    for (let pair of pairs) {
      if (!pair.trim()) {
        continue;
      }
      const parts = pair.split('=');
      if (parts.length >= 2) {
        const key = parts[0].trim();
        const value = parts.slice(1).join('=').trim();
        this.cookieJar.set(key, value);
      }
    }
  }

  private initBaseUrl(): void {
    const stored = PreferenceUtil.read<string>(AppPreferenceKeys.prefName, (pref) => {
      return pref.getSync(AppPreferenceKeys.baseUrl, '') as string;
    }, '');
    if (stored) {
      this.baseUrlValue = this.normalizeBaseUrl(stored);
      return;
    }

    const saved = PreferenceUtil.write(AppPreferenceKeys.prefName, (pref) => {
      pref.putSync(AppPreferenceKeys.baseUrl, CommonConstant.BASE_URL);
    });
    if (saved) {
      this.baseUrlValue = CommonConstant.BASE_URL;
    }
  }

  private normalizeBaseUrl(url: string): string {
    const trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.slice(0, -1);
    }
    return trimmed;
  }

  public clearAuthorization(): void {
    this.authorization = '';
  }

  public clearCookies(): void {
    this.cookieJar.clear();
  }

  public getCookieHeader(): string {
    let cookies: string[] = [];
    this.cookieJar.forEach((value, key) => {
      cookies.push(`${key}=${value}`);
    });
    return cookies.join('; ');
  }

  public hasCookie(): boolean {
    return this.cookieJar.size > 0;
  }

  public async request<T = Object>(options: ApiRequestOptions, isRetry: boolean = false): Promise<ApiResponse<T>> {
    const requestUrl = UrlUtil.buildUrl(this.baseUrlValue, options.path);

    // 1. 请求前拦截：检查是否需要登录但本地无凭证
    if (options.includeAuthorization !== false) {
      if (!this.authorization || !this.hasCookie()) {
        // [修改] 如果没有凭证，尝试调用一次重登录（可能是因为App刚启动内存被回收，但本地有密码）
        if (!isRetry && this.reLoginHandler) {
          LogUtil.warn(TAG, `本地无凭证，尝试自动登录: ${requestUrl}`);
          const success = await this.reLoginHandler();
          if (success) {
            return this.request<T>(options, true);
          }
        }

        LogUtil.warn(TAG, `拦截请求 ${requestUrl}: 本地未登录且自动登录失败`);
        this.handleLoginRedirect('请先登录');
        return Promise.reject(new Error('Local: Not logged in'));
      }
    }

    const httpRequest = http.createHttp();

    try {
      const headers = this.composeHeaders(options);

      let method = http.RequestMethod.GET;
      if (options.method) {
        method = options.method;
      }

      let requestOptions: http.HttpRequestOptions = {
        method: method,
        header: headers,
        extraData: options.data
      };

      const response: http.HttpResponse = await httpRequest.request(requestUrl, requestOptions);

      const setCookies = this.extractSetCookies(response);
      if (setCookies.length > 0) {
        this.mergeCookies(setCookies);
      }

      if (response.responseCode === 401 || response.responseCode === 403) {
        LogUtil.warn(TAG, `请求鉴权失败 ${response.responseCode}: ${requestUrl}`);

        // [新增] 尝试使用永久存储的账号密码获取新的凭证
        if (!isRetry && this.reLoginHandler) {
          LogUtil.info(TAG, '尝试自动重新登录...');
          const success = await this.reLoginHandler();
          if (success) {
            LogUtil.info(TAG, '自动重登录成功，重试原请求');
            return this.request<T>(options, true);
          }
        }

        this.handleLoginRedirect('登录状态已失效，请重新登录');
        throw new Error(`Auth failed: ${response.responseCode}`);
      }

      if (response.responseCode < 200 || response.responseCode >= 300) {
        throw new Error(`请求失败，状态码：${response.responseCode}`);
      }

      let expectJson = true;
      if (options.expectJson === false) {
        expectJson = false;
      }
      const parsedResult = this.parseResult<T>(response.result, expectJson);

      let responseHeaders: Record<string, string | string[]> = {};
      if (response.header) {
        let headerObj = response.header as Record<string, string | string[]>;
        let keys = Object.keys(headerObj);
        for (let i = 0; i < keys.length; i++) {
          let key = keys[i];
          let value = headerObj[key];
          if (value !== undefined) {
            responseHeaders[key] = value;
          }
        }
      }

      return {
        status: response.responseCode,
        data: parsedResult,
        headers: responseHeaders,
        cookies: setCookies,
        raw: response
      };
    } catch (error) {
      LogUtil.error(TAG, `Request failed for ${requestUrl}`, JSON.stringify(error));
      throw new Error(error);
    } finally {
      httpRequest.destroy();
    }
  }

  private handleLoginRedirect(message: string): void {
    if (this.isRedirecting) {
      return;
    }
    this.isRedirecting = true;
    ToastUtil.showInfo(message);
    RouterUtil.replacePathByName(RouterMap.LOGIN); // 使用 replace 防止返回
    setTimeout(() => {
      this.isRedirecting = false;
    }, 1000);
  }

  private parseResult<T>(payload: Object | string | ArrayBuffer, expectJson: boolean): T {
    if (!expectJson) {
      return payload as T;
    }
    if (typeof payload === 'string') {
      try {
        return JSON.parse(payload) as T;
      } catch (e) {
        return payload as T;
      }
    }
    return payload as T;
  }

  private composeHeaders(options: ApiRequestOptions): Record<string, string> {
    const headers: Record<string, string> = {};
    if (options.headers) {
      const keys = Object.keys(options.headers);
      for (let i = 0; i < keys.length; i++) {
        let key = keys[i];
        headers[key] = options.headers[key];
      }
    }

    if (options.requireNewApiHeader) {
      if (!headers['X-Uestc-Bbs']) {
        headers['X-Uestc-Bbs'] = '1';
      }
    }

    if (options.includeAuthorization !== false && this.authorization) {
      if (!headers['Authorization']) {
        headers['Authorization'] = this.authorization;
      }
    }

    const hasCookieHeader = headers['Cookie'] || headers['cookie'];
    if (options.includeCookie !== false && !hasCookieHeader) {
      const cookieHeader = this.getCookieHeader();
      if (cookieHeader) {
        headers['Cookie'] = cookieHeader;
      }
    }

    return headers;
  }

  private mergeCookies(setCookies: string[]): void {
    for (let i = 0; i < setCookies.length; i++) {
      let cookieStr = setCookies[i];
      let parts = cookieStr.split(';');
      if (parts.length > 0) {
        let pair = parts[0];
        let kv = pair.split('=');
        if (kv.length >= 2) {
          let key = kv[0].trim();
          let value = kv.slice(1).join('=').trim();
          this.cookieJar.set(key, value);
        }
      }
    }
  }

  private extractSetCookies(response: http.HttpResponse): string[] {
    const cookies: string[] = [];
    if (response.header) {
      let headerObj = response.header as Record<string, string | string[]>;
      let setCookie = headerObj['Set-Cookie'] ?? headerObj['set-cookie'];
      if (setCookie) {
        if (typeof setCookie === 'string') {
          cookies.push(setCookie);
        } else if (Array.isArray(setCookie)) {
          let cookieArray = setCookie as string[];
          for (let i = 0; i < cookieArray.length; i++) {
            cookies.push(cookieArray[i]);
          }
        }
      }
    }
    return cookies;
  }

  public async requestLegacy<T = Object>(
    module: string,
    action: string,
    params: Record<string, Object> = {}
  ): Promise<ApiResponse<T>> {
    const rParam = `${module}/${action}`;
    const requestUrl = `${this.baseUrlValue}${this.legacyBasePath}?r=${rParam}`;

    const apphash = await LegacyUtil.getAppHashValue();
    const authModel = StorageManager.authModel;

    // 组装 POST Body 参数 (ArkTS 兼容写法)
    // 注意：这里不再放入 'r' 参数，因为它已经在 URL 里了
    let bodyParams: Record<string, Object> = {
      'apphash': apphash,
      'platType': '1',
      'forumKey': 'CBQJazn9Wws8Ivhr6U',
      'sdkVersion': '2.4.0.2'
    };

    // 手动合并业务参数 params 到 bodyParams
    let keys = Object.keys(params);
    for (let i = 0; i < keys.length; i++) {
      let key = keys[i];
      bodyParams[key] = params[key];
    }

    // 注入旧版认证参数 (如果存在)
    LogUtil.debug(TAG, authModel.accessToken, " | ", authModel.accessSecret)
    if (authModel.accessToken && authModel.accessSecret) {
      bodyParams['accessToken'] = authModel.accessToken;
      bodyParams['accessSecret'] = authModel.accessSecret;
    }

    // 将 Body 参数序列化为 URL 编码格式 (key=val&key2=val2)
    const paramKeys = Object.keys(bodyParams);
    let urlParamsArr: string[] = [];
    for (let i = 0; i < paramKeys.length; i++) {
      let key = paramKeys[i];
      let val = bodyParams[key];
      // 务必进行 encodeURIComponent，防止特殊字符破坏格式
      urlParamsArr.push(`${key}=${encodeURIComponent(String(val))}`);
    }
    const urlParams = urlParamsArr.join('&');

    const httpRequest = http.createHttp();

    try {
      // 显式定义 headers 类型
      let headers: Record<string, string> = {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
        'Cookie': this.getCookieHeader() // 复用 Cookie，确保 Session 延续
      };

      // 显式定义请求选项
      let requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: urlParams // 序列化后的参数字符串
      };

      // 发送请求
      const response: http.HttpResponse = await httpRequest.request(requestUrl, requestOptions);

      // 处理 Set-Cookie
      const setCookies = this.extractSetCookies(response);
      if (setCookies.length > 0) {
        this.mergeCookies(setCookies);
      }

      // 解析结果
      // 注意：response.result 可能是 JSON 字符串，也可能是对象，parseResult 会处理
      const parsedResult = this.parseResult<T>(response.result, true);

      // 提取响应头
      let responseHeaders: Record<string, string | string[]> = {};
      if (response.header) {
        let headerObj = response.header as Record<string, string | string[]>;
        let hKeys = Object.keys(headerObj);
        for (let i = 0; i < hKeys.length; i++) {
          let key = hKeys[i];
          let value = headerObj[key];
          if (value !== undefined) {
            responseHeaders[key] = value;
          }
        }
      }

      return {
        status: response.responseCode,
        data: parsedResult,
        headers: responseHeaders,
        cookies: setCookies,
        raw: response
      };

    } catch (error) {
      LogUtil.error(TAG, `Legacy Request failed: ${rParam}`, JSON.stringify(error));
      throw new Error(String(error));
    } finally {
      httpRequest.destroy();
    }
  }

  public async requestHtml(
    phpFile: string,
    params: Record<string, string | number | boolean> = {},
    method: http.RequestMethod = http.RequestMethod.GET // [新增参数]
  ): Promise<Document> {
    const apphash = await LegacyUtil.getAppHashValue();

    // 1. 准备所有参数（公共参数 + 业务参数）
    let finalParams: Record<string, string | number | boolean> = {
      'apphash': apphash,
      'platType': '1',
      'forumKey': 'CBQJazn9Wws8Ivhr6U',
      'sdkVersion': '2.4.0.2'
    };

    let keys = Object.keys(params);
    for (let i = 0; i < keys.length; i++) {
      let key = keys[i];
      finalParams[key] = params[key];
    }

    const httpRequest = http.createHttp();

    try {
      // 2. 构造 Header
      const headers = {
        'Cookie': this.getCookieHeader(),
        'User-Agent': this.USER_AGENT
      } as Record<string, Object>;

      let requestUrl = UrlUtil.buildUrl(this.baseUrlValue, phpFile);
      let extraData: string | undefined = undefined;

      // 3. 根据 Method 处理参数位置
      if (method === http.RequestMethod.POST) {
        // POST: 参数放入 Body (x-www-form-urlencoded)
        let bodyParts: string[] = [];
        const finalKeys = Object.keys(finalParams);
        for (let i = 0; i < finalKeys.length; i++) {
          let key = finalKeys[i];
          let val = finalParams[key];
          bodyParts.push(`${key}=${encodeURIComponent(String(val))}`);
        }
        extraData = bodyParts.join('&');
        headers['Content-Type'] = 'application/x-www-form-urlencoded';
      } else {
        // GET: 参数拼接到 URL Query
        let queryParts: string[] = [];
        const finalKeys = Object.keys(finalParams);
        for (let i = 0; i < finalKeys.length; i++) {
          let key = finalKeys[i];
          let val = finalParams[key];
          queryParts.push(`${key}=${encodeURIComponent(String(val))}`);
        }
        const queryString = queryParts.join('&');
        if (queryString) {
          requestUrl = `${requestUrl}?${queryString}`;
        }
      }

      // 4. 发起请求
      const response = await httpRequest.request(requestUrl, {
        method: method,
        header: headers,
        extraData: extraData
      });

      // 5. 处理 Cookie 和 返回结果
      const setCookies = this.extractSetCookies(response);
      if (setCookies.length > 0) {
        this.mergeCookies(setCookies);
      }

      if (response.responseCode === 200) {
        if (typeof response.result === 'string') {
          return parseDocument(response.result);
        } else {
          throw new Error(`Response result is not string`);
        }
      } else {
        throw new Error(`HTML Request failed with code: ${response.responseCode}`);
      }

    } catch (error) {
      LogUtil.error(TAG, `RequestHtml failed: ${phpFile}`, JSON.stringify(error));
      throw new Error(String(error));
    } finally {
      httpRequest.destroy();
    }
  }

  public get baseUrl(): string {
    return this.baseUrlValue;
  }
}
