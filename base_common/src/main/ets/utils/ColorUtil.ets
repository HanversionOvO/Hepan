import { LogUtil } from '@pura/harmony-utils';

const TAG = '[ColorUtil]: ';
const DEFAULT_STABLE_COLORS: string[] = [
  '#FFF28B82',
  '#FFF6C177',
  '#FF8FD1A6',
  '#FF7FB8F6',
  '#FFA3B6F8',
  '#FFF0A1C0',
  '#FF9FD9D3',
  '#FFD3C28A'
];

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
 * ArkTS 内部使用的 RGBA/ARGB 颜色类
 * 这里我们用 a/r/g/b 四通道，a 范围 0-255
 */
class ARGB {
  a: number = 255;
  r: number = 0;
  g: number = 0;
  b: number = 0;
}

export class ColorUtil {
  public static getStableColor(seed?: string | number, palette: string[] = DEFAULT_STABLE_COLORS): string {
    if (!palette || palette.length === 0) {
      return '#FFBDBDBD';
    }
    const key = seed === undefined || seed === null ? '' : String(seed);
    if (!key) {
      return palette[0];
    }
    let hash = 0;
    for (let i = 0; i < key.length; i++) {
      hash = (hash * 31 + key.charCodeAt(i)) >>> 0;
    }
    return palette[hash % palette.length];
  }

  public static buildDiagonalGradient(
    colorHex: string,
    angle: number = 45,
    lightAmount: number = 0.2,
    darkAmount: number = 0.2
  ): LinearGradientOptions {
    const start = ColorUtil.lighten(colorHex, lightAmount);
    const end = ColorUtil.darken(colorHex, darkAmount);
    return {
      angle,
      colors: [[start, 0.0], [end, 1.0]]
    };
  }
  /**
   * 生成颜色的变体（浅色、深色、暗色）
   * lightLevel/darkLevel: 0~1，越大变化越明显
   */
  public static generateVariants(
    colorHex: string,
    lightLevel: number = 0.35,
    darkLevel: number = 0.35
  ): ColorVariants {
    return {
      origin: colorHex,
      light: ColorUtil.lighten(colorHex, lightLevel),
      dark: ColorUtil.darken(colorHex, darkLevel),
      dim: ColorUtil.darken(colorHex, Math.min(1, darkLevel * 2.0))
    };
  }

  /**
   * 变浅颜色 (与白色混合)
   */
  public static lighten(colorHex: string, amount: number = 0.85): string {
    // 白色不需要 alpha（mix 会保留 colorHex 的 alpha）
    return ColorUtil.mix(colorHex, '#FFFFFF', amount);
  }

  /**
   * 变深颜色 (与黑色混合)
   */
  public static darken(colorHex: string, amount: number = 0.85): string {
    return ColorUtil.mix(colorHex, '#000000', amount);
  }

  /**
   * 调整透明度（ARGB：#AARRGGBB）
   * opacity: 0~1
   */
  public static opacity(colorHex: string, opacity: number = 0.15): string {
    const c = ColorUtil.parseColor(colorHex);
    if (!c) {
      return colorHex;
    }

    const a = Math.round(Math.max(0, Math.min(1, opacity)) * 255);
    c.a = a;
    return ColorUtil.toHex(c, true); // 强制 ARGB 输出更符合你的用法
  }

  /**
   * 混合两种颜色（按 weight 线性插值）
   * - 只混合 RGB
   * - Alpha 保留 color1 的 alpha（更符合“明暗变化不改透明度”）
   */
  private static mix(color1: string, color2: string, weight: number): string {
    const w = Math.max(0, Math.min(1, weight));
    const c1 = ColorUtil.parseColor(color1);
    const c2 = ColorUtil.parseColor(color2);

    if (!c1 || !c2) {
      return color1;
    }

    const r = Math.round(c1.r + (c2.r - c1.r) * w);
    const g = Math.round(c1.g + (c2.g - c1.g) * w);
    const b = Math.round(c1.b + (c2.b - c1.b) * w);

    const out = new ARGB();
    out.a = c1.a; // 保留原 alpha
    out.r = r;
    out.g = g;
    out.b = b;

    // 这里：如果你希望永远输出 ARGB，就传 true
    return ColorUtil.toHex(out, true);
  }

  /**
   * 解析颜色字符串（支持 #RGB/#RRGGBB/#AARRGGBB 和 0xAARRGGBB）
   * 约定：8位字符串一律视为 ARGB（AA RR GG BB）
   */
  private static parseColor(input: string): ARGB | null {
    let s = input.trim();

    // 支持 0xAARRGGBB
    if (s.startsWith('0x') || s.startsWith('0X')) {
      s = '#' + s.slice(2);
    }

    if (!s.startsWith('#')) {
      // 没有 # 的情况，尽量容错
      s = '#' + s;
    }

    let hex = s.slice(1);

    // #RGB => #RRGGBB
    if (hex.length === 3) {
      hex = hex.split('').map(c => c + c).join('');
    }

    // #RRGGBB => 默认 alpha=FF
    if (hex.length === 6) {
      const c = new ARGB();
      c.a = 255;
      c.r = parseInt(hex.slice(0, 2), 16);
      c.g = parseInt(hex.slice(2, 4), 16);
      c.b = parseInt(hex.slice(4, 6), 16);
      if (Number.isNaN(c.r) || Number.isNaN(c.g) || Number.isNaN(c.b)) {
        LogUtil.error(TAG, `Invalid hex color: ${input}`);
        return null;
      }
      return c;
    }

    // #AARRGGBB（ARGB）
    if (hex.length === 8) {
      const c = new ARGB();
      c.a = parseInt(hex.slice(0, 2), 16);
      c.r = parseInt(hex.slice(2, 4), 16);
      c.g = parseInt(hex.slice(4, 6), 16);
      c.b = parseInt(hex.slice(6, 8), 16);
      if (Number.isNaN(c.a) || Number.isNaN(c.r) || Number.isNaN(c.g) || Number.isNaN(c.b)) {
        LogUtil.error(TAG, `Invalid hex color: ${input}`);
        return null;
      }
      return c;
    }

    LogUtil.error(TAG, `Invalid color format: ${input} (expect #RGB/#RRGGBB/#AARRGGBB or 0xAARRGGBB)`);
    return null;
  }

  /**
   * 输出 hex
   * forceARGB=true：永远输出 #AARRGGBB
   * forceARGB=false：alpha=FF 输出 #RRGGBB，否则 #AARRGGBB
   */
  private static toHex(c: ARGB, forceARGB: boolean = false): string {
    const to2 = (n: number): string => {
      const v = Math.max(0, Math.min(255, Math.round(n)));
      return v.toString(16).padStart(2, '0').toUpperCase();
    };

    const a = to2(c.a);
    const r = to2(c.r);
    const g = to2(c.g);
    const b = to2(c.b);

    if (forceARGB) {
      return `#${a}${r}${g}${b}`;
    }

    return (c.a >= 255) ? `#${r}${g}${b}` : `#${a}${r}${g}${b}`;
  }
}
