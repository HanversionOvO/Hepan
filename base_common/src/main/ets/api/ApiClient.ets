import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';
import { LegacyUtil } from '../utils/LegacyUtil';
import { RouterMap, RouterUtil } from '../utils/RouterUtil';
import { StorageManager } from '../utils/StorageManager';
import { ToastUtil } from '../utils/ToastUtil';

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
  private readonly baseUrl: string = 'https://bbs.uestc.edu.cn';
  private readonly legacyBaseUrl: string = 'http://bbs.uestc.edu.cn/mobcent/app/web/index.php';
  private readonly cookieJar: Map<string, string> = new Map();
  private authorization: string = '';
  private isRedirecting: boolean = false; // 防止并发跳转
  private reLoginHandler: ReLoginHandler | null = null;

  private constructor() {
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
    const requestUrl = this.buildUrl(options.path);

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

  private buildUrl(path: string): string {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return `${this.baseUrl}${path}`;
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
    const requestUrl = this.legacyBaseUrl;
    const rParam = `${module}/${action}`;

    // 1. 获取基础校验参数
    const apphash = await LegacyUtil.getAppHashValue();
    const authModel = StorageManager.authModel;

    // [修复Error 2] ArkTS 不支持对象展开运算符 (...params)，需要手动合并
    let bodyParams: Record<string, Object> = {
      'r': rParam,
      'apphash': apphash,
      'platType': '1',
      'forumKey': 'CBQJazn9Wws8Ivhr6U',
      'sdkVersion': '2.4.0.2'
    };

    // 手动遍历 params 进行赋值
    let keys = Object.keys(params);
    for (let i = 0; i < keys.length; i++) {
      let key = keys[i];
      bodyParams[key] = params[key];
    }

    // 注入旧版认证参数
    if (authModel.accessToken && authModel.accessSecret) {
      bodyParams['accessToken'] = authModel.accessToken;
      bodyParams['accessSecret'] = authModel.accessSecret;
    }

    // 构造 URLSearchParams 格式的字符串
    const paramKeys = Object.keys(bodyParams);
    let urlParamsArr: string[] = [];
    for (let i = 0; i < paramKeys.length; i++) {
      let key = paramKeys[i];
      let val = bodyParams[key];
      urlParamsArr.push(`${key}=${encodeURIComponent(String(val))}`);
    }
    const urlParams = urlParamsArr.join('&');

    const httpRequest = http.createHttp();

    try {
      // [修复Error 1] 显式定义 header 和 options 类型，避免字面量类型推断错误
      let headers: Record<string, string> = {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
        'Cookie': this.getCookieHeader()
      };

      let requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: urlParams
      };

      const response: http.HttpResponse = await httpRequest.request(requestUrl, requestOptions);

      const setCookies = this.extractSetCookies(response);
      if (setCookies.length > 0) {
        this.mergeCookies(setCookies);
      }

      // [修复Error 3 & 4] 去除 <any>，使用泛型 <T>，parseResult 本身支持泛型
      const parsedResult = this.parseResult<T>(response.result, true);

      // 构造返回头 (ArkTS 中处理 Record 需要小心)
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
      // 这里的 error 类型在 catch 中默认为 Object，为了抛出 Error 需要处理
      throw new Error(String(error));
    } finally {
      httpRequest.destroy();
    }
  }
}