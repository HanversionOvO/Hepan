import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';
import { ApiClient } from './ApiClient';
import { AdoptLegacyAuthResponse, LoginResult } from './models/AuthModels';
import { StorageManager } from '../utils/StorageManager'; // [新增]

const TAG = '[AuthApi]: ';

/**
 * 登录相关接口封装
 */
export class AuthApi {
  private static instance: AuthApi | null = null;
  private readonly client = ApiClient.getInstance();

  private constructor() {
    // [新增] 初始化时注册自动登录处理器给 ApiClient
    this.client.setReloginHandler(async () => {
      return await this.executeAutoLogin();
    });
  }

  public static getInstance(): AuthApi {
    if (!AuthApi.instance) {
      AuthApi.instance = new AuthApi();
    }
    return AuthApi.instance;
  }

  /**
   * 统一登录流程
   * 成功后会自动更新 AuthModel 并持久化
   */
  public async login(username: string, password: string): Promise<LoginResult> {
    // 登录前清除临时凭证，但保留 AuthModel 中的记录（稍后覆盖）
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

    const cookie = this.client.getCookieHeader();

    // [新增] 登录成功，更新并持久化 AuthModel (包含密码)
    const authModel = StorageManager.authModel;
    authModel.authorization = authorization;
    authModel.cookie = cookie;
    authModel.uid = uid;
    authModel.username = resultName;
    authModel.password = password; // 保存密码
    authModel.saveToDisk();

    return {
      authorization: authorization,
      cookie: cookie,
      uid: uid,
      username: resultName
    };
  }

  /**
   * [新增] 内部自动登录逻辑
   * 使用 AuthModel 中持久化存储的密码进行尝试
   */
  private async executeAutoLogin(): Promise<boolean> {
    const authModel = StorageManager.authModel;
    const username = authModel.username;
    const password = authModel.password;

    if (!username || !password) {
      LogUtil.warn(TAG, '自动登录失败: 本地无账号或密码记录');
      return false;
    }

    try {
      LogUtil.info(TAG, `正在尝试自动登录: ${username}`);
      await this.login(username, password);
      LogUtil.info(TAG, '自动登录成功');
      return true;
    } catch (e) {
      LogUtil.error(TAG, '自动登录失败', JSON.stringify(e));
      return false;
    }
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

  private parseLoginErrorMessage(content: string): string {
    try {
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
    return '账号或密码错误，或触发了登录限制';
  }
}