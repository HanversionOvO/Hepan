import { LogUtil } from '@pura/harmony-utils';
import { ApiClient } from '../api/ApiClient';
import { AuthPreferenceKeys, PreferenceUtil } from '../utils/PreferenceUtil';

const TAG = '[AuthModel]';

export interface AdoptLegacyAuthData {
  authorization: string;
  uid: number;
  user_settings_version: number;
  user_frontend_settings: Record<string, Object>;
}

export interface AdoptLegacyAuthUser {
  uid: number;
  username: string;
  new_pm_legacy: boolean;
  new_notification: number;
  new_pm: number;
  new_grouppm_legacy: boolean;
  settings_version: number;
}

export interface AdoptLegacyAuthSystem {
  settings_version: number;
  client_version: number;
}

export interface AdoptLegacyAuthResponse {
  code: number;
  message: string;
  data: AdoptLegacyAuthData;
  user: AdoptLegacyAuthUser;
  system: AdoptLegacyAuthSystem;
}

export interface LoginResult {
  authorization: string;
  cookie: string;
  uid: number;
  username: string;
}

export interface LegacyLoginData {
  token: string;
  secret: string;
  uid: number;
  userName: string;
}

export interface LegacyLoginResponse {
  token: string;
  secret: string;
  rs: number;
  errcode: string;
  body: LegacyLoginData
}

@ObservedV2
export class AuthModel {
  @Trace authorization: string = '';
  @Trace cookie: string = '';
  @Trace uid: number = 0;
  @Trace username: string = '';
  @Trace password: string = '';
  @Trace accessToken: string = '';
  @Trace accessSecret: string = '';

  constructor() {
    // 初始化时从本地加载数据
    this.loadFromDisk();
  }

  get isLoggedIn(): boolean {
    return !!this.authorization && !!this.cookie;
  }

  reset(): void {
    this.authorization = '';
    this.cookie = '';
    this.uid = 0;
    this.username = '';
    this.password = '';
    this.accessToken = '';
    this.accessSecret = '';
    this.saveToDisk();

    // 同步清空 ApiClient
    ApiClient.getInstance().clearAuthorization();
    ApiClient.getInstance().clearCookies();
  }

  /**
   * 保存数据到首选项
   */
  public saveToDisk(): void {
    const saved = PreferenceUtil.write(AuthPreferenceKeys.prefName, (pref) => {
      pref.putSync(AuthPreferenceKeys.authorization, this.authorization);
      pref.putSync(AuthPreferenceKeys.cookie, this.cookie);
      pref.putSync(AuthPreferenceKeys.uid, this.uid);
      pref.putSync(AuthPreferenceKeys.username, this.username);
      pref.putSync(AuthPreferenceKeys.password, this.password);
      pref.putSync(AuthPreferenceKeys.accessToken, this.accessToken);
      pref.putSync(AuthPreferenceKeys.accessSecret, this.accessSecret);
    });
    if (saved) {
      LogUtil.info(TAG, 'Auth data saved to disk.');
    }
  }

  /**
   * 从首选项加载数据
   */
  private loadFromDisk(): void {
    const loaded = PreferenceUtil.read(AuthPreferenceKeys.prefName, (pref) => {
      this.authorization = pref.getSync(AuthPreferenceKeys.authorization, '') as string;
      this.cookie = pref.getSync(AuthPreferenceKeys.cookie, '') as string;
      this.uid = pref.getSync(AuthPreferenceKeys.uid, 0) as number;
      this.username = pref.getSync(AuthPreferenceKeys.username, '') as string;
      this.password = pref.getSync(AuthPreferenceKeys.password, '') as string;
      this.accessToken = pref.getSync(AuthPreferenceKeys.accessToken, '') as string;
      this.accessSecret = pref.getSync(AuthPreferenceKeys.accessSecret, '') as string;
      return true;
    }, false);

    if (!loaded) {
      return;
    }

    const client = ApiClient.getInstance();

    if (this.authorization) {
      client.setAuthorization(this.authorization);
    }

    if (this.cookie) {
      client.setCookieString(this.cookie);
    }

    LogUtil.info(TAG, `Auth data loaded and synced. UID: ${this.uid}`);
  }
}
