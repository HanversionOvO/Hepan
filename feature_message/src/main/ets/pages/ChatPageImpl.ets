import { Chat, CommonConstant, RecentMessage } from 'base_common';
import { CustomFacePanel, FloatButton } from 'base_ui';
import { ChatBottomBar } from '../components/ChatBottomBar';
import { ChatBubble } from '../components/ChatBubble';
import { ChatNavBar } from '../components/ChatNavBar';
import { ChatNewMessageTip } from '../components/ChatNewMessageTip';
import { ChatPageVM } from '../viewmodels/ChatPageVM';
import { AppUtil } from '@pura/harmony-utils';

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
            .zIndex(2)
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
            CommonConstant.IconSizeLarge + (this.vm.isShowFacePanel ? this.vm.window.windowHeight * 0.4 : 0))
            .animation({
              duration: CommonConstant.AnimationDurationNormal,
              curve: CommonConstant.AnimationCurveSpring
            })
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
        .maintainVisibleContentPosition(true)

        if (this.vm.isShowFacePanel) {
          Column()
            .width(CommonConstant.FullPercent)
            .height(CommonConstant.FullPercent)
            .backgroundColor(Color.Transparent)
            .zIndex(3)
            .onClick(() => {
              AppUtil.getUIContext().animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.isShowFacePanel = false;
              });
            })
        }

        ChatBottomBar({
          controller: this.vm.richEditorController,
          onFaceClick: () => {
            AppUtil.getUIContext().animateTo({
              duration: CommonConstant.AnimationDurationNormal,
              curve: CommonConstant.AnimationCurveSpring
            }, () => {
              this.vm.isShowFacePanel = !this.vm.isShowFacePanel;
            });
          }
        })
          .position({
            bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding +
              (this.vm.isShowFacePanel ? this.vm.window.windowHeight * 0.4 : 0)
          })
          .zIndex(4)

        if (this.vm.isShowFacePanel) {
          CustomFacePanel({
            vm: this.vm,
            onFaceClick: (url: string) => {
              this.vm.richEditorController.addImageSpan(url, {
                imageStyle: {
                  size: [CommonConstant.IconSizeLarge, CommonConstant.IconSizeLarge],
                  objectFit: ImageFit.Contain
                }
              })
            }
          })
            .height(this.vm.window.windowHeight * 0.4)
            .transition(TransitionEffect.move(TransitionEdge.BOTTOM))
            .position({ bottom: 0 })
            .zIndex(4)
        }

        if (this.vm.showNewMessageTip) {
          ChatNewMessageTip({
            vm: this.vm
          })
            .position({
              right: CommonConstant.PageLRPadding,
              bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding +
              CommonConstant.IconSizeLarge + CommonConstant.NormalContainerInnerPadding +
                (this.vm.isShowFacePanel ? this.vm.window.windowHeight * 0.4 : 0)
            })
            .zIndex(4)
        }

        FloatButton({ isFloating: this.vm.isHideNavBar })
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
      if (this.vm.isShowFacePanel) {
        AppUtil.getUIContext().animateTo({
          duration: CommonConstant.AnimationDurationNormal,
          curve: CommonConstant.AnimationCurveSpring
        }, () => {
          this.vm.isShowFacePanel = false;
        });
        return true;
      }
      this.vm.backPage();
      return true;
    })
  }
}