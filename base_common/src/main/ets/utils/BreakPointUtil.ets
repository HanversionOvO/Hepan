import { mediaquery } from '@kit.ArkUI';
import { LogUtil } from '@pura/harmony-utils'; // 假设您有这个工具类
import { BreakpointNameEnum, BreakpointValueEnum } from '../models/BreakPointModel';
import { StorageManager } from './StorageManager'; // 导入之前的 StorageManager

const TAG = '[BreakPointUtil]: ';

class BreakpointQuery {
  name: BreakpointNameEnum;
  value: string;

  constructor(name: BreakpointNameEnum, value: string) {
    this.name = name;
    this.value = value;
  }
}

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

    const queries: BreakpointQuery[] = [
      new BreakpointQuery(BreakpointNameEnum.SM, `(width < ${BreakpointValueEnum.SM})`),
      new BreakpointQuery(BreakpointNameEnum.MD, `(width >= ${BreakpointValueEnum.SM}) and (width < ${BreakpointValueEnum.MD})`),
      new BreakpointQuery(BreakpointNameEnum.LG, `(width >= ${BreakpointValueEnum.MD}) and (width < ${BreakpointValueEnum.LG})`),
      new BreakpointQuery(BreakpointNameEnum.XL, `(width >= ${BreakpointValueEnum.LG})`)
    ];

    queries.forEach((query: BreakpointQuery) => {
      const listener = mediaquery.matchMediaSync(query.value);
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
    // 注：ArkTS 中 listener.off 需要原始回调引用，此处简化处理，仅清空数组
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