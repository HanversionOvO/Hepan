import { VMManager } from 'base_common';
import { MinePageVM } from '../viewmodels/MinePageVM';
import { UserProfileView } from '../components/UserProfileView';

@ComponentV2
export struct MinePageImpl {
  // 使用 VMManager 单例，确保 Tab 切换状态保持
  @Local vm: MinePageVM = VMManager.get(MinePageVM, () => new MinePageVM())

  aboutToAppear(): void {
    this.vm.init('me');
    this.vm.startMine();
  }

  build() {
    Navigation() {
      UserProfileView({ vm: this.vm })
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.start_window_background'))
  }
}