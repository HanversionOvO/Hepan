import { mediaquery, MediaQuery } from '@kit.ArkUI';
import { LogUtil } from '@pura/harmony-utils';
import { BreakPointModel, BreakpointNameEnum, BreakpointValueEnum } from '../models/BreakPointModel';
import { StorageManager } from './StorageManager';

const TAG = '[BreakPointUtil] :'

export class BreakPointUtil {
  private static readonly RANGE_SM: string = `(width<${BreakpointValueEnum.SM})`;
  private static readonly RANGE_MD: string = `(width>=${BreakpointValueEnum.SM}) and (width<${BreakpointValueEnum.MD})`;
  private static readonly RANGE_LG: string = `(width>=${BreakpointValueEnum.MD}) and (width<${BreakpointValueEnum.LG})`;
  private static readonly RANGE_XL: string = `(width>=${BreakpointValueEnum.LG})`;
  private mediaQuery: MediaQuery;
  private smListen: mediaquery.MediaQueryListener;
  private mdListen: mediaquery.MediaQueryListener;
  private lgListen: mediaquery.MediaQueryListener;
  private xlListen: mediaquery.MediaQueryListener;
  private breakpointModel: BreakPointModel;

  constructor(mediaQuery: MediaQuery) {
    this.mediaQuery = mediaQuery;
    this.smListen = this.mediaQuery.matchMediaSync(BreakPointUtil.RANGE_SM);
    this.mdListen = this.mediaQuery.matchMediaSync(BreakPointUtil.RANGE_MD);
    this.lgListen = this.mediaQuery.matchMediaSync(BreakPointUtil.RANGE_LG);
    this.xlListen = this.mediaQuery.matchMediaSync(BreakPointUtil.RANGE_XL);
    this.breakpointModel = StorageManager.breakPointModel;
  }

  private updateBreakpoint: (value: string) => void = (value: string) => {
    LogUtil.info(TAG, `updateBreakpoint: ${value}`);
    this.breakpointModel.currentBreakPoint = value as BreakpointNameEnum;
  }
  private smFunc: (result: mediaquery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.SM);
    }
  }
  private mdFunc: (result: mediaquery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.MD);
    }
  }
  private lgFunc: (result: mediaquery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.LG);
    }
  }
  private xlFunc: (result: mediaquery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.XL);
    }
  }

  register() {
    LogUtil.info(TAG, 'register breakpoint listener.');
    this.smListen.on('change', this.smFunc);
    this.mdListen.on('change', this.mdFunc);
    this.lgListen.on('change', this.lgFunc);
    this.xlListen.on('change', this.xlFunc);
  }

  unRegister() {
    LogUtil.info(TAG, 'unregister breakpoint listener.');
    this.smListen.off('change', this.smFunc);
    this.mdListen.off('change', this.mdFunc);
    this.lgListen.off('change', this.lgFunc);
    this.xlListen.off('change', this.xlFunc);
  }
}