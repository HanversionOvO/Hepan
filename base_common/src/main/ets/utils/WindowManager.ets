import { AppUtil, LogUtil, WindowUtil } from '@pura/harmony-utils';
import { AppStorageV2, window } from '@kit.ArkUI';
import { WindowModel } from '../models/WindowModel';

const TAG = '[WindowManager]: ';

export class WindowManager {
  public static async setWinConfig() {
    await WindowUtil.setWindowLayoutFullScreen(true);
    WindowManager.setAvoidArea();
    WindowManager.onAvoidAreaChange();
    WindowManager.setWindowSize();
    WindowManager.onWindowChange();
  }

  public static setWindowSize() {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    let windowClass: window.Window = AppUtil.getMainWindow();
    windowModel.windowWidth = px2vp(windowClass.getWindowProperties().windowRect.width);
    windowModel.windowHeight = px2vp(windowClass.getWindowProperties().windowRect.height);
    windowModel.isFloatWindow = WindowUtil.getWindowStatus(windowClass) === window.WindowStatusType.FLOATING;
  }

  public static setAvoidArea() {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    let type = window.AvoidAreaType.TYPE_SYSTEM;
    let avoidArea = WindowUtil.getWindowAvoidArea(type);
    windowModel.windowTopPadding = px2vp(avoidArea.topRect.height);
    windowModel.windowBottomPadding = px2vp(AppUtil.getNavigationIndicatorHeight());
  }

  public static onAvoidAreaChange() {
    try {
      let windowClass: window.Window = AppUtil.getMainWindow();
      windowClass.on("avoidAreaChange", () => {
        WindowManager.setAvoidArea();
      })
    } catch (e) {
      LogUtil.error(TAG, 'Failed to onAvoidAreaChange. Cause: ' + JSON.stringify(e))
    }
  }

  public static onWindowChange() {
    try {
      let windowClass: window.Window = AppUtil.getMainWindow();
      windowClass.on("windowSizeChange", () => {
        WindowManager.setWindowSize();
      })
    } catch (e) {
      LogUtil.error(TAG, 'Failed to onWindowChange. Cause: ' + JSON.stringify(e))
    }
  }

  public static offAvoidAreaChange() {
    try {
      let windowClass: window.Window = AppUtil.getMainWindow();
      windowClass.off("avoidAreaChange");
    } catch (e) {
      LogUtil.error(TAG, 'Failed to offAvoidAreaChange. Cause: ' + JSON.stringify(e))
    }
  }

  public static offWindowChange() {
    try {
      let windowClass: window.Window = AppUtil.getMainWindow();
      windowClass.off("windowSizeChange");
    } catch (e) {
      LogUtil.error(TAG, 'Failed to offWindowChange. Cause: ' + JSON.stringify(e))
    }
  }
}