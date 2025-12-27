import { AppStorageV2 } from '@kit.ArkUI';
import { LogUtil } from '@pura/harmony-utils';

export enum ToastType {
  SUCCESS = 'success',
  ERROR = 'error',
  WARNING = 'warning',
  INFO = 'info'
}

export interface ToastOptions {
  message: string;
  type?: ToastType;
  duration?: number;
  bottomOffset?: number; // vp
}

export interface ToastItem {
  id: string;
  message: string;
  type: ToastType;
  duration: number;
  bottomOffset: number; // vp
}

@ObservedV2
export class ToastStore {
  @Trace queue: ToastItem[] = [];

  push(item: ToastItem) {
    this.queue = [...this.queue, item];
  }

  remove(id: string) {
    this.queue = this.queue.filter((it) => it.id !== id);
  }

  clear() {
    this.queue = [];
  }
}

interface ToastVisualStyle {
  icon: string;
  bgColor: string;
  textColor: string;
}

const DEFAULT_DURATION = 2000;
const DEFAULT_BOTTOM_OFFSET = 48; // vp

export class ToastManager {
  private static get store(): ToastStore {
    return AppStorageV2.connect(ToastStore, () => new ToastStore())!;
  }

  static show(options: ToastOptions): string | null {
    const message = options.message?.trim();
    if (!message) {
      LogUtil.warn('[ToastManager]', 'toast message is empty, skip show');
      return null;
    }

    const toast: ToastItem = {
      id: `${Date.now()}-${Math.random().toString(16).slice(2, 6)}`,
      message,
      type: options.type ?? ToastType.INFO,
      duration: Math.max(options.duration ?? DEFAULT_DURATION, 500),
      bottomOffset: options.bottomOffset ?? DEFAULT_BOTTOM_OFFSET
    };

    ToastManager.store.push(toast);
    setTimeout((): void => ToastManager.dismiss(toast.id), toast.duration);
    return toast.id;
  }

  static dismiss(id?: string) {
    if (id) {
      ToastManager.store.remove(id);
      return;
    }
    // 没有指定 id 时，按队列先进先出移除一个
    if (ToastManager.store.queue.length > 0) {
      const first = ToastManager.store.queue[0];
      ToastManager.store.remove(first.id);
    }
  }

  static showSuccess(message: string, duration?: number, bottomOffset?: number) {
    return ToastManager.show({ message, duration, bottomOffset, type: ToastType.SUCCESS });
  }

  static showError(message: string, duration?: number, bottomOffset?: number) {
    return ToastManager.show({ message, duration, bottomOffset, type: ToastType.ERROR });
  }

  static showWarning(message: string, duration?: number, bottomOffset?: number) {
    return ToastManager.show({ message, duration, bottomOffset, type: ToastType.WARNING });
  }

  static showInfo(message: string, duration?: number, bottomOffset?: number) {
    return ToastManager.show({ message, duration, bottomOffset, type: ToastType.INFO });
  }

  static getVisualStyle(type: ToastType): ToastVisualStyle {
    switch (type) {
      case ToastType.SUCCESS:
        return { icon: '✔️', bgColor: '#E8F8EE', textColor: '#1B8C48' };
      case ToastType.ERROR:
        return { icon: '✖️', bgColor: '#FDEBEC', textColor: '#C62828' };
      case ToastType.WARNING:
        return { icon: '⚠️', bgColor: '#FFF8E1', textColor: '#C77800' };
      case ToastType.INFO:
      default:
        return { icon: 'ℹ️', bgColor: '#E8F2FF', textColor: '#1E5AA7' };
    }
  }
}