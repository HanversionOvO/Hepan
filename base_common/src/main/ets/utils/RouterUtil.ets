const TAG = "[RouterUtil]: "

export enum StackEnum {
  MAIN = 'main',
  MESSAGE = 'message'
}

export enum RouterMap {
  SPLASH = 'SplashPage',
  HOME = 'HomePage',
  LOGIN = 'LoginPage',
  FANS = 'FansPage',
  USER_PROFILE = 'UserProfilePage',
  NOTICE_PAGE = 'NoticePage',
  CHAT_PAGE = 'ChatPage',
  TIE_CONTENT_PAGE = 'TieContentPage',
  REPLY_PAGE = 'ReplyPage',
  IMAGE_LONG_TAKE_PREVIEW = 'ImageLongTakePreviewPage',
  COLLECTION_CONTENT_PAGE = 'CollectionContentPage',
  WATER_PAGE = 'WaterPage',
}

@ObservedV2
export class RouterModel {
  @Trace messageStackSize: number = 0; // 监控 MESSAGE 栈的页面数量
}

@ObservedV2
export class RouterUtil {
  private static stackMap: Map<string, NavPathStack> = new Map([
    [StackEnum.MAIN, new NavPathStack()]
  ]);
  public static readonly routerModel: RouterModel = new RouterModel();

  private static updateStackSize(stackName: string) {
    if (stackName === StackEnum.MESSAGE) {
      const stack = RouterUtil.getStack(stackName);
      RouterUtil.routerModel.messageStackSize = stack.size();
    }
  }

  /**
   * 创建新栈 (显式创建)
   * @param stackName
   * @param isNew 是否强制新建
   */
  public static createStack(stackName: string, isNew: boolean = false): NavPathStack {
    if (isNew || !RouterUtil.stackMap.has(stackName)) {
      RouterUtil.stackMap.set(stackName, new NavPathStack());
    }
    return RouterUtil.getStack(stackName);
  }

  /**
   * 删除栈
   * @param stackName
   */
  public static deleteStack(stackName: string): void {
    if (RouterUtil.stackMap.has(stackName)) {
      RouterUtil.stackMap.delete(stackName);
      // [新增] 删除栈时也要更新状态
      if (stackName === StackEnum.MESSAGE) {
        RouterUtil.routerModel.messageStackSize = 0;
      }
    }
  }

  /**
   * 获取栈 (懒加载模式，确保返回实例)
   * @param name 栈名称，默认为 MAIN
   * @returns NavPathStack 实例
   */
  public static getStack(name: string = StackEnum.MAIN): NavPathStack {
    let stack = RouterUtil.stackMap.get(name);
    if (!stack) {
      stack = new NavPathStack();
      RouterUtil.stackMap.set(name, stack);
    }
    return stack;
  }

  /**
   * 跳转页面
   * @param name 路由名称
   * @param param 路由参数 (泛型 T)
   * @param onPop 返回回调
   * @param animated 是否动画
   * @param stackName 栈名称
   */
  public static pushPathByName<T extends Object>(
    name: RouterMap | string,
    param: T | null = null,
    onPop?: Callback<PopInfo>,
    animated: boolean = true,
    stackName: StackEnum = StackEnum.MAIN
  ): void {
    const stack = RouterUtil.getStack(stackName);
    if (onPop) {
      stack.pushPathByName(name as string, param, onPop, animated);
    } else {
      stack.pushPathByName(name as string, param, animated);
    }
    // [新增] 更新状态
    RouterUtil.updateStackSize(stackName);
  }

  /**
   * 更换页面 (Replace)
   */
  public static replacePathByName<T extends Object>(
    name: RouterMap | string,
    param: T | null = null,
    animated: boolean = true,
    stackName: string = StackEnum.MAIN
  ): void {
    const stack = RouterUtil.getStack(stackName);
    stack.replacePathByName(name as string, param, animated);
    // [新增] 更新状态 (Replace 不改变栈大小，但为了保险起见可以加上，或者忽略)
    RouterUtil.updateStackSize(stackName);
  }

  /**
   * 返回上一级 (Pop)
   */
  public static pop<T extends Object>(
    result?: T,
    animated: boolean = true,
    stackName: string = StackEnum.MAIN
  ): void {
    const stack = RouterUtil.getStack(stackName);
    if (result !== undefined && result !== null) {
      stack.pop(result, animated);
    } else {
      stack.pop(animated);
    }
    // [新增] 更新状态
    RouterUtil.updateStackSize(stackName);
  }

  /**
   * 返回指定页面 (PopToName)
   */
  public static popToName<T extends Object>(
    name: RouterMap | string,
    result?: T,
    animated: boolean = true,
    stackName: string = StackEnum.MAIN
  ): void {
    const stack = RouterUtil.getStack(stackName);
    if (result !== undefined && result !== null) {
      stack.popToName(name as string, result, animated);
    } else {
      stack.popToName(name as string, animated);
    }
    // [新增] 更新状态
    RouterUtil.updateStackSize(stackName);
  }

  /**
   * 获取路由参数
   * @param name
   * @returns T | null
   */
  public static getParamByName<T>(name: RouterMap | string, stackName: string = StackEnum.MAIN): T | null {
    const stack = RouterUtil.getStack(stackName);
    const params = stack.getParamByName(name as string) as T[];
    // 安全检查数组长度
    if (Array.isArray(params) && params.length > 0) {
      return params[params.length - 1];
    }
    return null;
  }

  /**
   * 清空栈
   */
  public static clearStack(animated?: boolean, stackName: string = StackEnum.MAIN): void {
    const stack = RouterUtil.getStack(stackName);
    stack.clear(animated);
    // [新增] 更新状态
    RouterUtil.updateStackSize(stackName);
  }
}