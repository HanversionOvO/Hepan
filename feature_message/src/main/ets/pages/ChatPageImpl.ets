import { LogUtil } from '@pura/harmony-utils';
import { Chat, CommonConstant, RecentMessage } from 'base_common';
import { FloatButton } from 'base_ui';
import { ChatBottomBar } from '../components/ChatBottomBar';
import { ChatBubble } from '../components/ChatBubble';
import { ChatNavBar } from '../components/ChatNavBar';
import { ChatPageVM } from '../viewmodels/ChatPageVM';

const TAG = '[ChatPageImpl]: ';

@ComponentV2
export struct ChatPageImpl {
  @Local vm: ChatPageVM = new ChatPageVM();

  private handleScroll(yOffset: number, scrollState: ScrollState) {
    if (scrollState === ScrollState.Scroll) {
      if (yOffset > CommonConstant.ScrollAnimationThreshold) {
        this.vm.toggleHeader(true);
      } else if (yOffset < -CommonConstant.ScrollAnimationThreshold) {
        this.vm.toggleHeader(false);
      }
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        if (!this.vm.isHideNavBar) {
          ChatNavBar({
            vm: this.vm
          })
        }

        List({
          space: CommonConstant.NormalContainerInnerPadding
        }) {
          ListItem()
            .height(this.vm.window.windowTopPadding + CommonConstant.TopBarHeight)

          ForEach(this.vm.chats, (chat: Chat) => {
            ListItem() {
              ChatBubble({
                chat: chat
              })
            }
          }, (chat: Chat) => `${chat.sender}_${chat.mid}_${chat.time}`)

          ListItem()
            .height(this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding +
            CommonConstant.IconSizeLarge)
        }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .stackFromEnd(true)
        .padding({
          left: CommonConstant.PageLRPadding,
          right: CommonConstant.PageLRPadding
        })
        .scrollBar(BarState.Off)
        .onWillScroll((yOffset, scrollState) => {
          this.handleScroll(yOffset, scrollState);
        })
        .onReachStart(() => {

        })
        .onReachEnd(async () => {
          this.vm.toggleHeader(false);
        })

        ChatBottomBar({ controller: this.vm.richEditorController })
          .position({
            bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding
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
          .expandSafeArea([SafeAreaType.KEYBOARD])
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
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