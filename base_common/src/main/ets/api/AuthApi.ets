import http from '@ohos.net.http';
import { LogUtil } from '@pura/harmony-utils';
import { ApiClient } from './ApiClient';
import {
  AdoptLegacyAuthResponse,
  LegacyLoginData, LegacyLoginResponse, LoginResult
} from './models/AuthModels';
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

    const legacyLogin = await this.loginToMobcent(username, password);

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
    authModel.uid = adoptResp.data.user.uid;
    authModel.username = adoptResp.data.user.username;
    authModel.password = password; // 保存密码
    authModel.accessToken = legacyLogin.token;
    authModel.accessSecret = legacyLogin.secret;
    authModel.saveToDisk();

    return {
      authorization: authorization,
      cookie: cookie,
      uid: uid,
      username: resultName
    };
  }

  private async loginToMobcent(username: string, password: string): Promise<LegacyLoginData> {
    // 调用 ApiClient 的 requestLegacy 方法
    // 此时 AuthModel 中还没有 Token，requestLegacy 会发送不带 Token 的请求，这对于 'user/login' 是正确的

    LogUtil.debug(TAG, username, password)

    const response = await this.client.requestLegacy<LegacyLoginResponse>('user', 'login', {
      "username": username,
      "password": password,
      "type": "login"
    });

    LogUtil.debug(TAG, JSON.stringify(response.data))

    const body = response.data.body;
    const rs = response.data.rs;

    if (rs === 1 && body) {
      const token = response.data.token || body.token;
      const secret = response.data.secret || body.secret;
      if (!token || !secret) {
        throw new Error('Legacy login returned empty token/secret');
      }
      LogUtil.info(TAG, `旧版登录成功, Token: ${token}`);
      return {
        token: token,
        secret: secret,
        uid: body.uid,
        userName: body.userName
      };
    } else {
      throw new Error(`旧版登录返回错误: ${response.data.errcode}`);
    }
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

}
