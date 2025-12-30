import cryptoFramework from '@ohos.security.cryptoFramework';
import { util } from '@kit.ArkTS';

export class LegacyUtil {
  private static readonly AUTH_KEY = 'appbyme_key'; // API.md 中写死的 key

  /**
   * 生成旧版 API 需要的 apphash
   * 算法: substr(md5(substr(time(), 0, 5).$authkey.$special), 8, 8)
   */
  public static async getAppHashValue(): Promise<string> {
    const timestamp = Math.floor(new Date().getTime() / 1000).toString();
    const timePrefix = timestamp.substring(0, 5);
    const rawString = timePrefix + LegacyUtil.AUTH_KEY;

    try {
      const md = cryptoFramework.createMd("MD5");
      await md.update({ data: new Uint8Array(new util.TextEncoder().encodeInto(rawString)) });
      const digest = await md.digest();

      // 转换 hex 字符串
      let hex = '';
      for (let i = 0; i < digest.data.length; i++) {
        let byte = digest.data[i] & 0xFF;
        hex += ('00' + byte.toString(16)).slice(-2);
      }

      // 截取中间8位 (index 8, length 8)
      return hex.substring(8, 16);
    } catch (e) {
      console.error('MD5 calculation failed', e);
      return '';
    }
  }
}