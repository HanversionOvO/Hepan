import { Chat, CommonConstant, RecentMessage } from 'base_common';
import { CustomFacePanel, CustomFilePanel, FloatButton } from 'base_ui';
import { ChatBottomBar } from '../components/ChatBottomBar';
import { ChatBubble } from '../components/ChatBubble';
import { ChatNavBar } from '../components/ChatNavBar';
import { ChatNewMessageTip } from '../components/ChatNewMessageTip';
import { ChatPageVM } from '../viewmodels/ChatPageVM';
import { AppUtil } from '@pura/harmony-utils';
import { inputMethod } from '@kit.IMEKit';
import { window } from '@kit.ArkUI';

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

          // 底部垫片：根据面板状态调整高度
          ListItem()
            .height(this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding +
            CommonConstant.IconSizeLarge +
              (this.vm.isShowFacePanel || this.vm.isShowFilePanel ? this.vm.window.windowHeight * 0.4 : 0))
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
        .onClick(() => {
          // 关闭面板
          if (this.vm.isShowFacePanel || this.vm.isShowFilePanel) {
            AppUtil.getUIContext().animateTo({
              duration: CommonConstant.AnimationDurationNormal,
              curve: CommonConstant.AnimationCurveSpring
            }, () => {
              this.vm.isShowFacePanel = false;
              this.vm.isShowFilePanel = false;
            });
          }

          inputMethod.getController().hideTextInput();
        })

        ChatBottomBar({
          vm: this.vm,
          onFaceClick: () => {
            // 处理表情面板点击
            if (this.vm.isShowFacePanel) {
              AppUtil.getUIContext().animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.isShowFacePanel = false;
              });
            } else {
              // 开启表情面板前，关闭键盘和文件面板
              inputMethod.getController().hideTextInput();
              AppUtil.getUIContext().animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.isShowFilePanel = false; // 互斥关闭文件面板
                this.vm.isShowFacePanel = true;
              });
            }
          },
          onFileClick: () => {
            // 处理文件面板点击
            if (this.vm.isShowFilePanel) {
              AppUtil.getUIContext().animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.isShowFilePanel = false;
              });
            } else {
              // 开启文件面板前，关闭键盘和表情面板
              inputMethod.getController().hideTextInput();
              AppUtil.getUIContext().animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.isShowFacePanel = false; // 互斥关闭表情面板
                this.vm.isShowFilePanel = true;
              });
            }
          }
        })
          .position({
            bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding +
              (this.vm.isShowFacePanel || this.vm.isShowFilePanel ? this.vm.window.windowHeight * 0.4 : 0)
          })
          .zIndex(2)

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
            .transition(TransitionEffect.move(TransitionEdge.BOTTOM)
              .animation({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }))
            .position({ bottom: 0 })
            .zIndex(3)
        }

        if (this.vm.isShowFilePanel) {
          CustomFilePanel({
            vm: this.vm,
            items: this.vm.filePanelItems
          })
            .transition(TransitionEffect.move(TransitionEdge.BOTTOM)
              .animation({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }))
            .position({ bottom: 0 })
            .zIndex(3)
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
            .zIndex(2)
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

      // 新增：监听键盘高度变化
      // 当键盘弹出（高度>0）时，自动关闭表情面板
      const win = await window.getLastWindow(AppUtil.getContext());
      win.on('keyboardHeightChange', (data) => {
        if (data > 0 && this.vm.isShowFacePanel) {
          this.vm.isShowFacePanel = false;
        }
      });
    })
    .onWillDisappear(() => {
      this.vm.stopListen();
      window.getLastWindow(AppUtil.getContext()).then(win => {
        win.off('keyboardHeightChange');
      });
    })
    .onBackPressed(() => {
      // 物理返回键优先处理面板
      if (this.vm.isShowFacePanel) {
        this.vm.isShowFacePanel = false;
        return true;
      }
      this.vm.backPage();
      return true;
    })
  }
}