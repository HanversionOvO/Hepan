import { DialogHub } from '@hadss/dialoghub';
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { MessageManager, WindowManager } from 'base_common';
import { LoneTakeAnimationsTransition } from 'base_ui';

const TAG = '[EntryAbility]: ';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      AppUtil.init(this.context);
      DialogHub.init(AppUtil.getUIContext());
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      LogUtil.error(TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    LogUtil.info(TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    LogUtil.info(TAG, '%{public}s', 'Ability onDestroy');
    WindowManager.offAvoidAreaChange();
    WindowManager.offWindowChange();
    MessageManager.getInstance().stop();
  }

  onForeground(): void {
    LogUtil.info(TAG, '%{public}s', 'Ability onForeground');
    MessageManager.getInstance().setForegroundState(true);
  }

  onBackground(): void {
    LogUtil.info(TAG, '%{public}s', 'Ability onBackground');
    MessageManager.getInstance().setForegroundState(false);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    LogUtil.info(TAG, '%{public}s', 'Ability onWindowStageCreate');
    WindowManager.setWinConfig();
    LoneTakeAnimationsTransition.init(windowStage);

    windowStage.loadContent('pages/splash/pages/SplashPage', (err) => {
      if (err.code) {
        LogUtil.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      LogUtil.info(TAG, 'Succeeded in loading the content.');
    });
  }
}
