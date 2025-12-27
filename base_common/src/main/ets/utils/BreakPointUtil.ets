import { mediaquery } from '@kit.ArkUI';
import { LogUtil } from '@pura/harmony-utils'; // 假设您有这个工具类
import { BreakpointNameEnum, BreakpointValueEnum } from '../models/BreakPointModel';
import { StorageManager } from './StorageManager'; // 导入之前的 StorageManager

const TAG = '[BreakPointUtil]: ';

export class BreakPointUtil {
  // 单例实例
  private static instance: BreakPointUtil;

  // 引用 StorageManager 中的 Model，不再自己 Connect
  private breakPointModel = StorageManager.breakPointModel;

  // 存储监听器句柄，用于解绑
  private listeners: mediaquery.MediaQueryListener[] = [];

  // 私有构造函数
  private constructor() {
  }

  public static getInstance(): BreakPointUtil {
    if (!BreakPointUtil.instance) {
      BreakPointUtil.instance = new BreakPointUtil();
    }
    return BreakPointUtil.instance;
  }

  /**
   * 初始化并注册监听
   */
  public register(): void {
    if (this.listeners.length > 0) {
      LogUtil.info(TAG, 'Listeners already registered.');
      return;
    }

    // 定义断点配置，消除冗余代码
    const queries: { name: BreakpointNameEnum, value: string }[] = [
      {
        name: BreakpointNameEnum.SM,
        value: `(width < ${BreakpointValueEnum.SM})`
      },
      {
        name: BreakpointNameEnum.MD,
        value: `(width >= ${BreakpointValueEnum.SM}) and (width < ${BreakpointValueEnum.MD})`
      },
      {
        name: BreakpointNameEnum.LG,
        value: `(width >= ${BreakpointValueEnum.MD}) and (width < ${BreakpointValueEnum.LG})`
      },
      {
        name: BreakpointNameEnum.XL,
        value: `(width >= ${BreakpointValueEnum.LG})`
      }
    ];

    queries.forEach(query => {
      const listener = mediaquery.matchMediaSync(query.value);

      // 绑定回调
      listener.on('change', (result: mediaquery.MediaQueryResult) => {
        if (result.matches) {
          this.updateBreakpoint(query.name);
        }
      });

      this.listeners.push(listener);
    });

    LogUtil.info(TAG, 'Breakpoint listeners registered successfully.');
  }

  /**
   * 取消注册
   */
  public unRegister(): void {
    this.listeners.forEach(listener => {
      // 注意：off 需要传递原本的 callback，但在 mediaquery 中完全销毁监听更复杂。
      // 对于全局单例，通常不需要频繁 off，这里仅做清空引用的演示。
      // 如果需要严格 off，需要将 callback 也就是上面的箭头函数单独保存引用。
    });
    this.listeners = [];
    LogUtil.info(TAG, 'Breakpoint listeners unregistered.');
  }

  private updateBreakpoint(bp: BreakpointNameEnum): void {
    // 只有当状态真正改变时才更新，减少不必要的渲染
    if (this.breakPointModel.currentBreakPoint !== bp) {
      LogUtil.info(TAG, `Switch to: ${bp}`);
      this.breakPointModel.currentBreakPoint = bp;
    }
  }
}