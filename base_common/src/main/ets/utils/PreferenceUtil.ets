import { preferences } from '@kit.ArkData';
import { AppUtil, LogUtil } from '@pura/harmony-utils';

const TAG = '[PreferenceUtil]';

export class AuthPreferenceKeys {
  public static readonly prefName: string = 'auth_data_pref';
  public static readonly authorization: string = 'authorization';
  public static readonly cookie: string = 'cookie';
  public static readonly uid: string = 'uid';
  public static readonly username: string = 'username';
  public static readonly password: string = 'password';
  public static readonly accessToken: string = 'access_token';
  public static readonly accessSecret: string = 'access_secret';
}

export class PreferenceUtil {
  public static read<T>(name: string, action: (pref: preferences.Preferences) => T, fallback: T): T {
    try {
      const context = AppUtil.getContext();
      const pref = preferences.getPreferencesSync(context, { name: name });
      return action(pref);
    } catch (err) {
      LogUtil.error(TAG, `Failed to read preferences: ${name}`, JSON.stringify(err));
      return fallback;
    }
  }

  public static write(name: string, action: (pref: preferences.Preferences) => void): boolean {
    try {
      const context = AppUtil.getContext();
      const pref = preferences.getPreferencesSync(context, { name: name });
      action(pref);
      pref.flush();
      return true;
    } catch (err) {
      LogUtil.error(TAG, `Failed to write preferences: ${name}`, JSON.stringify(err));
      return false;
    }
  }
}
