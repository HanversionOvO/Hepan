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
  [BreakpointNameEnum.SM]?: T,
  [BreakpointNameEnum.MD]?: T,
  [BreakpointNameEnum.LG]?: T,
  [BreakpointNameEnum.XL]?: T,
}

export class BreakpointType<T> {
  private options: BreakpointTypeOptions<T>;

  constructor(options: BreakpointTypeOptions<T>) {
    this.options = options;
  }

  public getValue(bp: BreakpointNameEnum) {
    return Reflect.get(this.options, bp) as T;
  }
}

@ObservedV2
export class BreakPointModel {
  @Trace currentBreakPoint: BreakpointNameEnum = BreakpointNameEnum.SM;
}