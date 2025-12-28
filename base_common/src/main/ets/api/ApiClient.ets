import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';

const TAG = '[ApiClient]: ';

export interface ApiRequestOptions<T = Object> {
  path: string;
  method?: http.RequestMethod;
  headers?: Record<string, string>;
  data?: T;
  expectJson?: boolean;
  includeAuthorization?: boolean;
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
  private readonly cookieJar: Map<string, string> = new Map();
  private authorization: string = '';

  private constructor() {
  }

  public static getInstance(): ApiClient {
    if (!ApiClient.instance) {
      ApiClient.instance = new ApiClient();
    }
    return ApiClient.instance;
  }

  public setAuthorization(token: string): void {
    if (token) {
      this.authorization = token;
    } else {
      this.authorization = '';
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

  public setCookieString(cookieStr: string): void {
    if (!cookieStr) {
      this.cookieJar.clear();
      return;
    }
    // 解析分号分隔的 Cookie 字符串
    const pairs = cookieStr.split(';');
    for (let pair of pairs) {
      if (!pair.trim()) {
        continue;
      }
      const parts = pair.split('=');
      if (parts.length >= 2) {
        const key = parts[0].trim();
        // 重新拼接 value，防止 value 中包含 = 号
        const value = parts.slice(1).join('=').trim();
        this.cookieJar.set(key, value);
      }
    }
  }

  public async request<T = Object>(options: ApiRequestOptions): Promise<ApiResponse<T>> {
    const httpRequest = http.createHttp();
    const requestUrl = this.buildUrl(options.path);

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

      if (response.responseCode < 200 || response.responseCode >= 300) {
        throw new Error(`请求失败，状态码：${response.responseCode}`);
      }

      let expectJson = true;
      if (options.expectJson === false) {
        expectJson = false;
      }
      const parsedResult = this.parseResult<T>(response.result, expectJson);

      // Handle headers safely for ArkTS
      let responseHeaders: Record<string, string | string[]> = {};
      if (response.header) {
        // Cast to Record to allow indexed access: headerObj[key]
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
      throw new Error('网络请求失败');
    } finally {
      httpRequest.destroy();
    }
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
      // Cast to Record to allow indexed access
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
}