export enum BreakpointNameEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

export enum BreakpointValueEnum {
  SM = '600vp',
  MD = '840vp',
  LG = '1440vp',
}

export interface BreakpointTypeOptions<T> {
  [BreakpointNameEnum.SM]?: T;
  [BreakpointNameEnum.MD]?: T;
  [BreakpointNameEnum.LG]?: T;
  [BreakpointNameEnum.XL]?: T;
}

export class BreakpointType<T> {
  private options: BreakpointTypeOptions<T>;

  constructor(options: BreakpointTypeOptions<T>) {
    this.options = options;
  }

  /**
   * 根据传入的断点名称获取对应的值
   * @param bp 断点名称
   * @returns 对应的值
   */
  public getValue(bp: BreakpointNameEnum): T | undefined {
    return this.options[bp];
  }
}

@ObservedV2
export class BreakPointModel {
  @Trace currentBreakPoint: BreakpointNameEnum = BreakpointNameEnum.SM;
}