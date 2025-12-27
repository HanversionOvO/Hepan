import { LogUtil } from '@pura/harmony-utils';

const TAG = '[ColorUtil]: ';

/**
 * 颜色变体结果接口
 */
export interface ColorVariants {
  origin: string; // 原色
  light: string; // 浅色 (Tint)
  dark: string; // 深色 (Shade)
  dim: string; // 暗色 (更深)
}

/**
 * 内部使用的 RGB 类
 * 解决 arkts-no-obj-literals-as-types 错误
 */
class RGB {
  r: number = 0;
  g: number = 0;
  b: number = 0;
}

export class ColorUtil {
  /**
   * 生成颜色的变体（浅色、深色、暗色）
   */
  public static generateVariants(colorHex: string, lightLevel: number = 0.2, darkLevel: number = 0.2): ColorVariants {
    // 显式声明类型以符合 ArkTS 规范
    const variants: ColorVariants = {
      origin: colorHex,
      light: ColorUtil.lighten(colorHex, lightLevel),
      dark: ColorUtil.darken(colorHex, darkLevel),
      dim: ColorUtil.darken(colorHex, darkLevel * 2.5)
    };
    return variants;
  }

  /**
   * 变浅颜色 (与白色混合)
   */
  public static lighten(colorHex: string, amount: number = 0.8): string {
    return ColorUtil.mix(colorHex, '#FFFFFF', amount);
  }

  /**
   * 变深颜色 (与黑色混合)
   */
  public static darken(colorHex: string, amount: number = 0.8): string {
    return ColorUtil.mix(colorHex, '#000000', amount);
  }

  /**
   * 调整透明度
   */
  public static opacity(colorHex: string, opacity: number): string {
    let hex = colorHex.replace('#', '');
    if (hex.length === 3) {
      hex = hex.split('').map(c => c + c).join('');
    }
    if (hex.length !== 6) {
      LogUtil.error(TAG, `Invalid color format for opacity: ${colorHex}`);
      return colorHex;
    }

    const alpha = Math.round(opacity * 255);
    const alphaHex = (alpha | 1 << 8).toString(16).slice(1).toUpperCase();
    return `#${hex}${alphaHex}`;
  }

  /**
   * 混合两种颜色
   */
  private static mix(color1: string, color2: string, weight: number): string {
    weight = Math.max(0, Math.min(1, weight));

    const rgb1 = ColorUtil.hexToRgb(color1);
    const rgb2 = ColorUtil.hexToRgb(color2);

    if (!rgb1 || !rgb2) {
      return color1;
    }

    const r = Math.round(rgb1.r + (rgb2.r - rgb1.r) * weight);
    const g = Math.round(rgb1.g + (rgb2.g - rgb1.g) * weight);
    const b = Math.round(rgb1.b + (rgb2.b - rgb1.b) * weight);

    return ColorUtil.rgbToHex(r, g, b);
  }

  /**
   * Hex 转 RGB
   * 修改点：返回类型改为 RGB 类，解决 arkts-no-obj-literals-as-types
   */
  private static hexToRgb(hex: string): RGB | null {
    hex = hex.replace('#', '');

    if (hex.length === 3) {
      hex = hex.split('').map(c => c + c).join('');
    }

    if (hex.length !== 6) {
      LogUtil.error(TAG, `Invalid hex color: ${hex}`);
      return null;
    }

    const bigint = parseInt(hex, 16);

    // 修改点：实例化 RGB 类，解决 arkts-no-untyped-obj-literals
    let color = new RGB();
    color.r = (bigint >> 16) & 255;
    color.g = (bigint >> 8) & 255;
    color.b = bigint & 255;

    return color;
  }

  /**
   * RGB 转 Hex
   */
  private static rgbToHex(r: number, g: number, b: number): string {
    return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1).toUpperCase();
  }
}