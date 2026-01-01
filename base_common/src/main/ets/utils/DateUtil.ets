import { ResUtil } from '@pura/harmony-utils';

export class DateUtil {
  /**
   * 格式化时间戳为相对时间（如：xx秒前、xx分钟前）
   * @param timestamp 时间戳（毫秒）
   * @returns 格式化后的字符串
   */
  public static getRelativeTime(timestamp: number): string {
    if (timestamp < 10000000000) {
      timestamp *= 1000;
    }
    const now = new Date().getTime();
    const diff = now - timestamp;

    const seconds = Math.floor(diff / 1000);

    if (seconds < 0) {
      return ResUtil.getStringSync($r('app.string.DateUtil_justnow'));
    }

    if (seconds < 60) {
      return `${Math.max(1, seconds)}${ResUtil.getStringSync($r('app.string.DateUtil_second_before'))}`;
    }

    if (seconds < 60 * 60) {
      const minutes = Math.floor(seconds / 60);
      return `${minutes}${ResUtil.getStringSync($r('app.string.DateUtil_min_before'))}`;
    }

    if (seconds < 60 * 60 * 24) {
      const hours = Math.floor(seconds / 3600);
      return `${hours}${ResUtil.getStringSync($r('app.string.DateUtil_hour_before'))}`;
    }

    const days = Math.floor(seconds / 86400);
    return `${days}${ResUtil.getStringSync($r('app.string.DateUtil_day_before'))}`;
  }
}