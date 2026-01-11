import { LogUtil } from '@pura/harmony-utils';
import { ApiClient } from '../api/ApiClient';
import { PreferenceUtil } from '../utils/PreferenceUtil';

const TAG = '[AuthModel]';
const PREF_NAME = 'auth_data_pref';
const KEY_AUTH = 'authorization';
const KEY_COOKIE = 'cookie';
const KEY_UID = 'uid';
const KEY_USERNAME = 'username';
const KEY_PASSWORD = 'password';
const KEY_ACCESS_TOKEN = 'access_token';
const KEY_ACCESS_SECRET = 'access_secret';

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
    const saved = PreferenceUtil.write(PREF_NAME, (pref) => {
      pref.putSync(KEY_AUTH, this.authorization);
      pref.putSync(KEY_COOKIE, this.cookie);
      pref.putSync(KEY_UID, this.uid);
      pref.putSync(KEY_USERNAME, this.username);
      pref.putSync(KEY_PASSWORD, this.password);
      pref.putSync(KEY_ACCESS_TOKEN, this.accessToken);
      pref.putSync(KEY_ACCESS_SECRET, this.accessSecret);
    });
    if (saved) {
      LogUtil.info(TAG, 'Auth data saved to disk.');
    }
  }

  /**
   * 从首选项加载数据
   */
  private loadFromDisk(): void {
    const loaded = PreferenceUtil.read(PREF_NAME, (pref) => {
      this.authorization = pref.getSync(KEY_AUTH, '') as string;
      this.cookie = pref.getSync(KEY_COOKIE, '') as string;
      this.uid = pref.getSync(KEY_UID, 0) as number;
      this.username = pref.getSync(KEY_USERNAME, '') as string;
      this.password = pref.getSync(KEY_PASSWORD, '') as string;
      this.accessToken = pref.getSync(KEY_ACCESS_TOKEN, '') as string;
      this.accessSecret = pref.getSync(KEY_ACCESS_SECRET, '') as string;
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
