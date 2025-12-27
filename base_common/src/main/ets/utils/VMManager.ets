import { LogUtil } from "@pura/harmony-utils";
import { BaseVM } from "../viewmodels/BaseVM";
import { TypeConstructorWithArgs } from "@ohos.arkui.StateManagement";

const TAG = '[VMManager]: '

@ObservedV2
export class VMManager {
  private static instances: Map<string, BaseVM> = new Map();

  /**
   * 获取 ViewModel 单例
   * @param vmClass VM 类 (如 HomePageVM)
   */
  public static get<T extends BaseVM>(vmClass: TypeConstructorWithArgs<T>, factory: () => T): T {
    const key = vmClass.name;

    if (!VMManager.instances.has(key)) {
      LogUtil.debug(TAG, `Create instance: ${key}`);
      // 使用工厂函数创建实例，避免动态 new
      VMManager.instances.set(key, factory());
    }

    return VMManager.instances.get(key) as T;
  }

  /**
   * 销毁指定 ViewModel (释放内存)
   * 适用于：退出登录、关闭非主页的大型模块等场景
   */
  public static destroy(vmClass: TypeConstructorWithArgs<BaseVM>) {
    const key = vmClass.name;
    if (VMManager.instances.has(key)) {
      LogUtil.debug(TAG, `Destroy instance: ${key}`);
      VMManager.instances.delete(key);
    }
  }

  /**
   * 清空所有 ViewModel
   */
  public static clearAll() {
    VMManager.instances.clear();
  }
}