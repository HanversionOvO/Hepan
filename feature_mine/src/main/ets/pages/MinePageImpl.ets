import { MinePageVM } from '../viewmodels/MinePageVM';
import { UserProfileView } from '../components/UserProfileView';

@ComponentV2
export struct MinePageImpl {
  @Local vm: MinePageVM = new MinePageVM()

  async aboutToAppear() {
    this.vm.init('me');
    await this.vm.startMine();
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