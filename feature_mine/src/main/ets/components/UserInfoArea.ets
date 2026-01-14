import { MinePageVM } from '../viewmodels/MinePageVM';
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import {
  ChatPageRouteParam,
  CommonConstant,
  MessageManager,
  RecentMessage,
  RouterMap,
  RouterUtil,
  StackEnum,
  ToastUtil,
  UserApi,
  UserAvatarUtil
} from 'base_common';
import { PasteboardUtil, ResUtil } from '@pura/harmony-utils';
import { GlassButton, ImageLongTakePreviewUtil } from 'base_ui';
import { UserStats, UserStatsModel } from './UserStats';
import { CardType, FeatureCard, FeatureCardModel } from './FeatureCard';
import { signatureSheetBuilder } from './SignatureSheet';
import { userProfileSheetBuilder } from './UserProfileSheet';
import { userMedalSheetBuilder } from './UserMedalSheet';

@ComponentV2
export struct UserInfoArea {
  @Param @Require vm: MinePageVM;
  @Local userAvatarSize: number = 96;
  @Local isAvatarShow: boolean = true;
  private baseComponentId: string = 'user_avatar_transition';

  @Computed
  get avatarTransitionId(): string {
    return `user_avatar_${this.vm.user?.user_summary?.uid || 'default'}`;
  }

  private async addFriend(): Promise<void> {
    const summary = this.vm.user?.user_summary;
    if (!summary || !summary.uid) {
      return;
    }

    const userName = summary.username?.trim() || '';
    try {
      const result = await UserApi.addFriend(summary.uid, '');
      summary.friend_status = result.friend_status;
      const message = userName ? `已向 ${userName} 发送添加好友请求` : '已发送添加好友请求';
      ToastUtil.showLightSuccess(message);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '添加好友失败';
      ToastUtil.showLightError(errorMessage);
    }
  }

  private confirmDeleteFriend(): void {
    const summary = this.vm.user?.user_summary;
    if (!summary || !summary.uid) {
      return;
    }
    const userName = summary.username?.trim();
    const message = userName ? `是否删除好友 ${userName}` : '是否删除好友';
    ToastUtil.showWarn(message, true, undefined, () => {
      void this.deleteFriend(summary.uid, userName || '');
    });
  }

  private async deleteFriend(uid: number, userName: string): Promise<void> {
    const result = await UserApi.deleteFriend(uid);
    if (result) {
      if (this.vm.user?.user_summary) {
        this.vm.user.user_summary.friend_status = undefined;
      }
      const successMessage = userName ? `成功删除好友 ${userName}` : '成功删除好友';
      ToastUtil.showLightSuccess(successMessage);
      void this.vm.onRefreshAll();
    } else {
      ToastUtil.showLightError('删除好友失败');
    }
  }

  private async openChat(): Promise<void> {
    const summary = this.vm.user?.user_summary;
    if (!summary || !summary.uid) {
      return;
    }
    const uid = summary.uid;
    const userName = summary.username?.trim() || '';
    const manager = MessageManager.getInstance();
    let existing = manager.findConversation(uid);
    if (!existing) {
      await manager.refreshMessageList();
      existing = manager.findConversation(uid);
    }
    let targetMessage: RecentMessage;
    if (existing) {
      targetMessage = existing;
    } else {
      const message = new RecentMessage();
      message.toUserId = uid;
      message.toUserName = userName;
      message.toUserAvatar = UserAvatarUtil.getAvatarUrl(uid);
      message.toUserIsBlack = '0';
      targetMessage = message;
    }

    const routeParam = new ChatPageRouteParam();
    routeParam.message = targetMessage;
    routeParam.stackName = StackEnum.MAIN;
    RouterUtil.pushPathByName(RouterMap.CHAT_PAGE, routeParam, undefined, true, StackEnum.MAIN);
  }

  @Builder
  UidCopyMenu() {
    Menu() {
      MenuItem({
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.hand_cut_and_paste')),
        content: $r('app.string.MinePage_copy_uid')
      })
        .onClick(() => {
          PasteboardUtil.setDataTextSync(this.vm.user?.user_summary?.uid.toString() || "")
          ToastUtil.showLightSuccess($r('app.string.CommonToast_copy_success'))
        })
    }
    .font({ size: CommonConstant.TextSizeNormal })
  }

  build() {
    Flex({
      direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.Column,
      space: {
        main: this.vm.isTabletView ? LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding) :
          LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding)
      },
      alignItems: ItemAlign.Center
    }) {
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        Row({ space: CommonConstant.NormalContainerLRPadding }) {
          Stack() {
            if (this.isAvatarShow && this.vm.user) {
              Image(UserAvatarUtil.getAvatarUrl(this.vm.user?.user_summary?.uid!))
                .width(this.userAvatarSize)
                .height(this.userAvatarSize)
                .borderRadius(CommonConstant.RadiusRound)
                .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })
                .geometryTransition(UserAvatarUtil.getAvatarUrl(this.vm.user.user_summary?.uid) + this.baseComponentId)
                .onClick(() => {
                  const uid = this.vm.user?.user_summary?.uid;
                  if (!uid) {
                    return;
                  }

                  ImageLongTakePreviewUtil.show({
                    uiContext: this.getUIContext(),
                    componentId: this.baseComponentId,
                    imageList: [UserAvatarUtil.getAvatarUrl(uid)],
                    selectedIndex: 0,
                    onShowAction: () => {
                      this.isAvatarShow = false;
                    },
                    onBackToFirstPage: () => {
                      this.isAvatarShow = true;
                    }
                  });
                })
            }
          }
          .width(this.userAvatarSize)
          .height(this.userAvatarSize)

          Column({ space: CommonConstant.NormalContainerTBPadding }) {
            // 昵称部分
            Text(this.vm.user?.user_summary?.username)
              .fontSize(CommonConstant.TextSizeUltraLarge)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_on_primary'))

            Text(`${ResUtil.getStringSync($r('app.string.MinePage_uid'))}: ${this.vm.user?.user_summary?.uid}`)
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_on_primary'))
              .bindContextMenu(this.UidCopyMenu, ResponseType.LongPress,
                {
                  preview: MenuPreviewMode.IMAGE,
                  previewAnimationOptions: { scale: [0.8, 1.0] },
                })
          }
          .alignItems(HorizontalAlign.Start)
        }

        Text(this.vm.user?.signature || $r('app.string.MinePage_signature_placeHolder'))
          .width(CommonConstant.FullPercent)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize(CommonConstant.TextSizeNormal)
          .margin({
            bottom: CommonConstant.NormalContainerTBPadding
          })
          .onClick(() => {
            if (this.vm.isMe) {
              this.vm.isShowSignatureSheet = true;
            }
          })
          .bindSheet($$this.vm.isShowSignatureSheet, signatureSheetBuilder(this.vm), {
            showClose: true,
            detents: [SheetSize.FIT_CONTENT],
            enableOutsideInteractive: false,
            preferType: this.vm.isTabletView ? SheetType.CENTER : SheetType.BOTTOM,
            backgroundColor: $r('app.color.start_window_background'),
            blurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
            title: {
              title: $r('app.string.MinePage_edit_sig')
            }
          })

        Row() {
          Row({ space: CommonConstant.NormalContainerInnerPadding }) {
            ForEach(this.vm.userStats, (item: UserStatsModel, index: number) => {
              UserStats({ userStatsModel: item })
            })
          }

          Row({ space: CommonConstant.SmallContainerInnerPadding }) {
            GlassButton({
              text: ResUtil.getStringSync($r('app.string.MinePage_check_profile')),
              innerFontColor: $r('sys.color.font_on_primary'),
              innerFontSize: CommonConstant.TextSizeSmall
            })
              .onClick(() => {
                this.vm.isShowUserProfileSheet = true;
              })
              .bindSheet($$this.vm.isShowUserProfileSheet, userProfileSheetBuilder(this.vm), {
                showClose: true,
                detents: [SheetSize.FIT_CONTENT],
                enableOutsideInteractive: false,
                preferType: this.vm.isTabletView ? SheetType.CENTER : SheetType.BOTTOM,
                backgroundColor: $r('app.color.start_window_background'),
                blurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
                title: {
                  title: $r('app.string.MinePage_user_profile')
                }
              })

            if (this.vm.isMe) {
              GlassButton({
                symbol: $r('sys.symbol.gearshape'),
                innerFontColor: $r('sys.color.font_on_primary'),
              })
            } else {
              if (this.vm.user?.user_summary?.friend_status === 'friend') {
                GlassButton({
                  symbol: $r('sys.symbol.person_badge_xmark_fill'),
                  innerFontColor: $r('sys.color.font_on_primary'),
                  innerFontSize: CommonConstant.TextSizeSmall
                })
                  .onClick(() => {
                    this.confirmDeleteFriend();
                  })
              } else if (!this.vm.user?.user_summary?.friend_status) {
                GlassButton({
                  symbol: $r('sys.symbol.person_badge_plus'),
                  innerFontColor: $r('sys.color.font_on_primary'),
                  innerFontSize: CommonConstant.TextSizeSmall
                })
                  .onClick(() => {
                    void this.addFriend();
                  })
              }

              GlassButton({
                symbol: $r('sys.symbol.message'),
                innerFontColor: $r('sys.color.font_on_primary'),
                innerFontSize: CommonConstant.TextSizeSmall
              })
                .onClick(() => {
                  void this.openChat();
                })
            }
          }
        }
        .width(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width(this.vm.isTabletView ? CommonConstant.BelowHalfPercent : CommonConstant.FullPercent)
      .alignItems(HorizontalAlign.Start)

      // 功能卡片区域
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        FeatureCard({
          vm: this.vm,
          cardType: CardType.LV_CARD
        })

        ForEach(this.vm.featureCards, (item: FeatureCardModel) => {
          FeatureCard({
            vm: this.vm,
            model: item
          })
        })
      }
      // 将勋章 Sheet 绑定到功能卡片区域
      .bindSheet($$this.vm.isShowMedalSheet, userMedalSheetBuilder(this.vm), {
        showClose: true,
        detents: [SheetSize.MEDIUM, SheetSize.LARGE],
        enableOutsideInteractive: false,
        preferType: this.vm.isTabletView ? SheetType.CENTER : SheetType.BOTTOM,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        backgroundColor: $r('app.color.start_window_background'),
        blurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
        title: {
          title: $r('app.string.MinePage_medal_center')
        }
      })
    }
    .width(CommonConstant.FullPercent)
    .padding({
      top: CommonConstant.TopBarHeight + this.vm.window.windowTopPadding,
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding
    })
  }
}
