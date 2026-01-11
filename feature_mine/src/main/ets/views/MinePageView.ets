import { MinePageVM } from '../viewmodels/MinePageVM';
import { UserProfileView } from '../components/UserProfileView';

@ComponentV2
export struct MinePageView {
  @Param @Require vm: MinePageVM;

  build() {
    Navigation() {
      UserProfileView({ vm: this.vm })
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.start_window_background'))
  }
}
