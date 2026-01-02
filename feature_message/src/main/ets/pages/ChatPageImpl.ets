import { LogUtil } from '@pura/harmony-utils';
import { CommonConstant, RecentMessage } from 'base_common';
import { FloatButton } from 'base_ui';
import { ChatNavBar } from '../components/ChatNavBar';
import { ChatPageVM } from '../viewmodels/ChatPageVM';

const TAG = '[ChatPageImpl]: ';

@ComponentV2
export struct ChatPageImpl {
  @Local vm: ChatPageVM = new ChatPageVM();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        ChatNavBar({
          vm: this.vm
        })

        FloatButton({ isFloating: this.vm.isHideNavBar, floatIconColor: $r('sys.color.font_on_primary') })
          .position({
            top: this.vm.window.windowTopPadding + (CommonConstant.TopBarHeight - CommonConstant.IconSizeLarge) / 2,
            left: CommonConstant.PageLRPadding
          })
          .onClick(() => {
            this.vm.backPage();
          })
          .zIndex(2)
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.start_window_background'))
    .onReady(async (context: NavDestinationContext) => {
      const params = context.pathInfo.param as RecentMessage;
      if (params) {
        this.vm.recentMessage = params;
        LogUtil.debug(TAG, JSON.stringify(this.vm.recentMessage))
        await this.vm.loadData();
      }
    })
    .onBackPressed(() => {
      this.vm.backPage();
      return true;
    })
  }
}