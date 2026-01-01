import { MinePageVM } from '../viewmodels/MinePageVM';
import { UserProfileView } from '../components/UserProfileView';

@ComponentV2
export struct UserProfilePage {
  // 每个用户页面使用独立的 VM 实例，互不干扰
  @Local vm: MinePageVM = new MinePageVM();

  build() {
    NavDestination() {
      UserProfileView({ vm: this.vm })
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      // 从路由参数中获取 uid
      const uid = context.pathInfo.param as number;
      if (uid) {
        this.vm.init(uid);
        this.vm.startMine();
      }
    })
    .backgroundColor($r('app.color.start_window_background'))
  }
}