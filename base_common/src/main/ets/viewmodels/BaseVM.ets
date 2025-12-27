import { WindowModel } from "../models/WindowModel";
import { StorageManager } from "../utils/StorageManager";
import { BreakPointModel, BreakpointNameEnum } from "../models/BreakPointModel";

export enum UiState {
  LOADING,
  SUCCESS,
  ERROR,
  EMPTY
}

@ObservedV2
export abstract class BaseVM {
  @Trace window: WindowModel = StorageManager.windowModel; // 窗口信息
  @Trace breakPoint: BreakPointModel = StorageManager.breakPointModel; // 断点信息
  @Trace uiState: UiState = UiState.SUCCESS;
  @Computed
  get isLoading(): boolean {
    return this.uiState === UiState.LOADING;
  }
  @Computed
  get isTabletView(): boolean {
    return this.breakPoint.currentBreakPoint === BreakpointNameEnum.LG ||
      this.breakPoint.currentBreakPoint === BreakpointNameEnum.XL;
  }

  loadData() {

  }

  showLoading() {
    this.uiState = UiState.LOADING;
  }

  showSuccess() {
    this.uiState = UiState.SUCCESS;
  }

  showError() {
    this.uiState = UiState.ERROR;
  }

  showEmpty() {
    this.uiState = UiState.EMPTY;
  }
}