import { WindowModel } from '../models/WindowModel';
import { StorageManager } from '../utils/StorageManager';
import { BreakPointModel, BreakpointNameEnum } from '../models/BreakPointModel';

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
  get isTabletView(): boolean {
    return this.breakPoint.currentBreakPoint === BreakpointNameEnum.LG ||
      this.breakPoint.currentBreakPoint === BreakpointNameEnum.XL;
  }

  protected setUiState(state: UiState): void {
    this.uiState = state;
  }

  protected setUiStateByList<T>(list: Array<T> | null | undefined): void {
    if (!list || list.length === 0) {
      this.uiState = UiState.EMPTY;
      return;
    }
    this.uiState = UiState.SUCCESS;
  }

  showLoading() {
    this.setUiState(UiState.LOADING);
  }

  showSuccess() {
    this.setUiState(UiState.SUCCESS);
  }

  showError() {
    this.setUiState(UiState.ERROR);
  }

  showEmpty() {
    this.setUiState(UiState.EMPTY);
  }
}
