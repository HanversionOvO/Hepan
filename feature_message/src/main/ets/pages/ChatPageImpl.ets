import { Chat, CommonConstant, RecentMessage } from 'base_common';
import { FloatButton } from 'base_ui';
import { ChatBottomBar } from '../components/ChatBottomBar';
import { ChatBubble } from '../components/ChatBubble';
import { ChatNavBar } from '../components/ChatNavBar';
import { ChatNewMessageTip } from '../components/ChatNewMessageTip';
import { ChatPageVM } from '../viewmodels/ChatPageVM';

const TAG = '[ChatPageImpl]: ';

@ComponentV2
export struct ChatPageImpl {
  @Local vm: ChatPageVM = new ChatPageVM();

  private handleScroll(yOffset: number, scrollState: ScrollState) {
    if (scrollState === ScrollState.Scroll) {
      if (yOffset > CommonConstant.ScrollAnimationThreshold) {
        this.vm.toggleHeader(false);
      } else if (yOffset < -CommonConstant.ScrollAnimationThreshold) {
        this.vm.toggleHeader(true);
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
          space: CommonConstant.NormalContainerInnerPadding,
          scroller: this.vm.chatScroller
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
        .onDidScroll((scrollOffset, scrollState) => {
          this.handleScroll(scrollOffset, scrollState);
        })
        .onScrollIndex((start, end) => {
          const totalCount = this.vm.chats.length;
          const isAtBottom = totalCount > 0 && end >= totalCount - 1;
          this.vm.updateBottomStatus(isAtBottom);
        })
        .onReachStart(async () => {
          await this.vm.loadHistory();
        })
        .onReachEnd(async () => {
          this.vm.toggleHeader(false);
        })

        ChatBottomBar({ controller: this.vm.richEditorController })
          .position({
            bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding
          })


        if (this.vm.showNewMessageTip) {
          ChatNewMessageTip({
            vm: this.vm
          })
            .position({
              right: CommonConstant.PageLRPadding,
              bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding +
              CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding
            })
        }

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
        await this.vm.startMessage();
      }
    })
    .onWillDisappear(() => {
      this.vm.stopListen();
    })
    .onBackPressed(() => {
      this.vm.backPage();
      return true;
    })
  }
}