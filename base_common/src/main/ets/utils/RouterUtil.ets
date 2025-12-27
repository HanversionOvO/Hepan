export enum StackEnum {
  MAIN = 'main'
}

export enum RouterMap {
  SPLASH = 'SplashPage'
}

@ObservedV2
export class RouterUtil {
  private static stackMap: Map<string, NavPathStack> = new Map([
    [StackEnum.MAIN, new NavPathStack()]
  ])

  /**
   * 创建新栈
   * @param stackName
   * @returns
   */
  public static createStack(stackName: string, isNew: boolean = false) {
    if (!RouterUtil.stackMap.has(stackName) || isNew) {
      RouterUtil.stackMap.set(stackName, new NavPathStack());
    }
    return RouterUtil.getStack(stackName);
  }

  /**
   * 删除栈
   * @param stackName
   */
  public static deleteStack(stackName: string) {
    if (RouterUtil.stackMap.has(stackName)) {
      RouterUtil.stackMap.delete(stackName);
    }
  }

  /**
   * 获取栈 (修复：确保单例，自动创建并保存)
   * @returns
   */
  public static getStack(name: string = StackEnum.MAIN): NavPathStack {
    // 如果 Map 中没有该名称的栈，则创建一个新的并保存
    if (!RouterUtil.stackMap.has(name)) {
      RouterUtil.stackMap.set(name, new NavPathStack());
    }
    // 返回 Map 中存储的唯一实例
    return RouterUtil.stackMap.get(name)!;
  }

  /**
   * 跳转页面
   * @param name
   * @param param
   * @param onPop
   * @param animated
   */
  public static pushPathByName(name: RouterMap, param: Object | null = null, onPop?: Callback<PopInfo>,
    animated: boolean = true, stackName: StackEnum = StackEnum.MAIN) {
    if (onPop) {
      RouterUtil.getStack(stackName).pushPathByName(name, param, onPop, animated);
    } else {
      RouterUtil.getStack(stackName).pushPathByName(name, param, animated);
    }
  }

  /**
   * 更换页面
   * @param name
   * @param param
   * @param animated
   */
  public static replacePathByName(name: RouterMap, param: Object | null = null, animated: boolean = true,
    stackName: string = StackEnum.MAIN) {
    RouterUtil.getStack(stackName).replacePathByName(name, param, animated);
  }

  /**
   * 返回上一级
   * @param result
   * @param animated
   */
  public static pop(result?: Object, animated?: boolean, stackName: string = StackEnum.MAIN) {
    if (result) {
      RouterUtil.getStack(stackName).pop(result, animated);
    } else {
      RouterUtil.getStack(stackName).pop(animated);
    }
  }

  /**
   * 返回指定页面
   * @param name
   * @param result
   * @param animated
   */
  public static popToName(name: RouterMap, result?: Object, animated?: boolean, stackName: string = StackEnum.Main) {
    if (result) {
      RouterUtil.getStack(stackName).popToName(name, result, animated);
    } else {
      RouterUtil.getStack(stackName).popToName(name, animated);
    }
  }

  /**
   * 获取路由参数
   * @param name
   * @returns
   */
  public static getParamByName<T>(name: RouterMap, stackName: string = StackEnum.MAIN): T | null {
    const params = RouterUtil.getStack(stackName).getParamByName(name) as T[];
    if (params.length && params[params.length - 1]) {
      return params[params.length - 1];
    }
    return null;
  }

  /**
   * 清空栈
   */
  public static clearStack(animated?: boolean, stackName: string = StackEnum.MAIN) {
    RouterUtil.getStack(stackName).clear(animated);
  }
}