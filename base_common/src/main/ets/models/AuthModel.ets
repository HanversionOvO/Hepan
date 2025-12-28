import { preferences } from '@kit.ArkData';
import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { ApiClient } from '../api/ApiClient';

const TAG = '[AuthModel]';
const PREF_NAME = 'auth_data_pref'; // 首选项文件名
const KEY_AUTH = 'authorization';
const KEY_COOKIE = 'cookie';
const KEY_UID = 'uid';
const KEY_USERNAME = 'username';

@ObservedV2
export class AuthModel {
  @Trace authorization: string = '';
  @Trace cookie: string = '';
  @Trace uid: number = 0;
  @Trace username: string = '';

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
    this.saveToDisk();

    // [新增] 同步清空 ApiClient
    ApiClient.getInstance().clearAuthorization();
    ApiClient.getInstance().clearCookies();
  }

  /**
   * 保存数据到首选项
   */
  public saveToDisk(): void {
    try {
      const context = AppUtil.getContext();
      const pref = preferences.getPreferencesSync(context, { name: PREF_NAME });
      pref.putSync(KEY_AUTH, this.authorization);
      pref.putSync(KEY_COOKIE, this.cookie);
      pref.putSync(KEY_UID, this.uid);
      pref.putSync(KEY_USERNAME, this.username);
      pref.flush(); // 强制刷盘
      LogUtil.info(TAG, 'Auth data saved to disk.');
    } catch (err) {
      LogUtil.error(TAG, 'Failed to save auth data', JSON.stringify(err));
    }
  }

  /**
   * 从首选项加载数据
   */
  private loadFromDisk(): void {
    try {
      const context = AppUtil.getContext();
      const pref = preferences.getPreferencesSync(context, { name: PREF_NAME });

      this.authorization = pref.getSync(KEY_AUTH, '') as string;
      this.cookie = pref.getSync(KEY_COOKIE, '') as string;
      this.uid = pref.getSync(KEY_UID, 0) as number;
      this.username = pref.getSync(KEY_USERNAME, '') as string;

      // =====================================================
      // [关键修复] 加载完成后，立即同步给 ApiClient
      // =====================================================
      const client = ApiClient.getInstance();

      // 1. 恢复 Authorization
      if (this.authorization) {
        client.setAuthorization(this.authorization);
      }

      // 2. 恢复 Cookie
      if (this.cookie) {
        client.setCookieString(this.cookie);
      }

      LogUtil.info(TAG, `Auth data loaded and synced. UID: ${this.uid}, Auth len: ${this.authorization.length}`);
    } catch (err) {
      LogUtil.error(TAG, 'Failed to load auth data', JSON.stringify(err));
    }
  }
}