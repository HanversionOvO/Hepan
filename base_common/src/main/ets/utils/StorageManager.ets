import { WindowModel } from '../models/WindowModel';
import { AppStorageV2 } from '@kit.ArkUI';
import { TypeConstructorWithArgs } from '@ohos.arkui.StateManagement';
import { LogUtil } from '@pura/harmony-utils';
import { BreakPointModel } from '../models/BreakPointModel';
import { AuthModel } from '../models/AuthModel';
import { TabIndexModel } from '../models/TabIndexModel';

const TAG = '[StorageManager]: '

@ObservedV2
export class StorageManager {
  /**
   * 获取窗口信息模型
   */
  public static get windowModel(): WindowModel {
    return StorageManager.connect(WindowModel, () => new WindowModel());
  }

  /**
   * 获取断点信息
   */
  public static get breakPointModel(): BreakPointModel {
    return StorageManager.connect(BreakPointModel, () => new BreakPointModel());
  }

  /**
   * 登录信息
   */
  public static get authModel(): AuthModel {
    return StorageManager.connect(AuthModel, () => new AuthModel());
  }

  /**
   * Tab栏索引
   */
  public static get tabIndexModel(): TabIndexModel {
    return StorageManager.connect(TabIndexModel, () => new TabIndexModel());
  }

  /**
   * 私有通用连接方法，封装非空断言和错误处理
   * @param type 类构造器
   * @param factory 工厂函数
   */
  private static connect<T extends object>(type: TypeConstructorWithArgs<T>, factory: () => T): T {
    try {
      // 统一调用 connect，并处理潜在的 undefined
      const instance = AppStorageV2.connect(type, factory);
      if (!instance) {
        // 理论上 connect 不会返回 undefined (如果 factory 提供了)，但为了稳健性加一层保底
        LogUtil.error(TAG, `Failed to connect ${type.name}, creating new instance locally.`);
        return factory();
      }
      return instance;
    } catch (error) {
      LogUtil.error(TAG, `Error connecting to AppStorageV2 for ${type.name}:`, error);
      return factory(); // 发生异常时降级处理，保证应用不崩
    }
  }
}