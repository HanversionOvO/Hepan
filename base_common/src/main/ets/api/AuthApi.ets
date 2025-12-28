import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';
import { ApiClient } from './ApiClient';
import { AdoptLegacyAuthResponse, LoginResult } from './models/AuthModels';

const TAG = '[AuthApi]: ';

/**
 * 登录相关接口封装
 */
export class AuthApi {
  private static instance: AuthApi | null = null;
  private readonly client = ApiClient.getInstance();

  private constructor() {
  }

  public static getInstance(): AuthApi {
    if (!AuthApi.instance) {
      AuthApi.instance = new AuthApi();
    }
    return AuthApi.instance;
  }

  /**
   * 统一登录流程
   */
  public async login(username: string, password: string): Promise<LoginResult> {
    this.client.clearAuthorization();
    this.client.clearCookies();

    await this.requestLegacyLogin(username, password);

    const adoptResp = await this.client.request<AdoptLegacyAuthResponse>({
      path: '/_/auth/adoptLegacyAuth',
      method: http.RequestMethod.POST,
      includeCookie: true,
      includeAuthorization: false,
      requireNewApiHeader: true
    });

    // Fix: No destructuring
    let data = adoptResp.data.data;
    let authorization = '';
    if (data) {
      authorization = data.authorization;
    }

    if (!authorization) {
      throw new Error('未获取到 Authorization');
    }

    this.client.setAuthorization(authorization);

    let uid = 0;
    if (adoptResp.data.user) {
      uid = adoptResp.data.user.uid;
    }

    let resultName = '';
    if (adoptResp.data.user) {
      resultName = adoptResp.data.user.username;
    }

    return {
      authorization: authorization,
      cookie: this.client.getCookieHeader(),
      uid: uid,
      username: resultName
    };
  }

  private async requestLegacyLogin(username: string, password: string): Promise<void> {
    const formBody =
      `loginfield=username&username=${encodeURIComponent(username)}&password=${encodeURIComponent(password)}`;

    const response = await this.client.request<string>({
      path: '/member.php?mod=logging&action=login&loginsubmit=yes&inajax=1',
      method: http.RequestMethod.POST,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      data: formBody,
      includeCookie: false,
      includeAuthorization: false,
      expectJson: false
    });

    if (!this.isLegacyLoginSuccess(response.data)) {
      LogUtil.error(TAG, 'Legacy login failed', JSON.stringify(response.data));
      const errorMessage = this.parseLoginErrorMessage(response.data);
      throw new Error(errorMessage);
    }
  }

  private isLegacyLoginSuccess(payload: Object | string): boolean {
    if (typeof payload !== 'string') {
      return false;
    }
    return payload.includes('succeedmessage') || payload.includes('欢迎您回来');
  }

  /**
   * 解析登录失败时的 XML 错误信息
   * XML 格式示例: <root><![CDATA[登录失败，您还可以尝试 3 次<script...
   */
  private parseLoginErrorMessage(content: string): string {
    try {
      // 1. 提取 CDATA 中的内容
      const cdataRegex = /<!\[CDATA\[([\s\S]*?)\]\]>/;
      const match = content.match(cdataRegex);

      if (match && match[1]) {
        let rawMessage = match[1];
        const messageParts = rawMessage.split('<script');
        if (messageParts.length > 0) {
          return messageParts[0].trim();
        }
      }
    } catch (e) {
      LogUtil.error(TAG, 'Failed to parse error message', JSON.stringify(e));
    }
    // 解析失败时的默认提示
    return '账号或密码错误，或触发了登录限制';
  }
}