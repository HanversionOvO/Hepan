// ==========================================
// 工具类：头像处理封装
// ==========================================

export class UserAvatarUtil {
  private static readonly BASE_AVATAR_URL = 'https://bbs.uestc.edu.cn/uc_server/avatar.php';

  /**
   * 获取用户头像 URL
   * @param uid 用户ID
   * @param size 头像大小: small, middle, big
   * @returns 完整的图片 URL
   */
  public static getAvatarUrl(uid: number, size: 'small' | 'middle' | 'big' = 'middle'): string {
    if (!uid) {
      return '';
    }
    return `${UserAvatarUtil.BASE_AVATAR_URL}?uid=${uid}&size=${size}`;
  }
}