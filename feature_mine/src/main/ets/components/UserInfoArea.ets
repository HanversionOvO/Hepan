import { MinePageVM } from '../viewmodels/MinePageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { CommonConstant, RouterMap, RouterUtil, UserAvatarUtil } from 'base_common';
import { ResUtil } from '@pura/harmony-utils';
import { GlassButton } from 'base_ui';
import { UserStats, UserStatsModel } from './UserStats';
import { CardType, FeatureCard, FeatureCardModel } from './FeatureCard';
import { signatureSheetBuilder } from './SignatureSheet';
import { userProfileSheetBuilder } from './UserProfileSheet';
import { userMedalSheetBuilder } from './UserMedalSheet'; // 新增

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
                .transition(TransitionEffect.opacity(0.99))
                .onClick(() => {
                  const uid = this.vm.user?.user_summary?.uid;
                  if (!uid) {
                    return;
                  }

                  const avatarUrl = UserAvatarUtil.getAvatarUrl(uid);

                  // 构造参数
                  let param: Record<string, Object> = {};
                  param.componentId = this.baseComponentId;
                  param.imageList = [avatarUrl]; // 预览列表（此处只有一张）
                  param.selectedIndex = 0;

                  param.onBackToFirstPage = () => {
                    this.isAvatarShow = true;
                  };

                  this.getUIContext().animateTo({
                    duration: CommonConstant.AnimationDurationNormal,
                    curve: CommonConstant.AnimationCurveSpring,
                  }, () => {
                    // 跳转到预览页
                    RouterUtil.pushPathByName(RouterMap.IMAGE_LONG_TAKE_PREVIEW, param, () => {
                    }, false);
                  });

                  // 隐藏当前页面的头像，交由预览页接管
                  this.isAvatarShow = false;
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
            blurStyle: BlurStyle.BACKGROUND_THICK,
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
                blurStyle: BlurStyle.BACKGROUND_THICK,
                title: {
                  title: $r('app.string.MinePage_user_profile')
                }
              })

            GlassButton({
              symbol: $r('sys.symbol.gearshape'),
              innerFontColor: $r('sys.color.font_on_primary'),
            })
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
      // 新增：将勋章 Sheet 绑定到功能卡片区域的 Row 上
      // 只要 isShowMedalSheet 变为 true，这里就会弹出 sheet
      .bindSheet($$this.vm.isShowMedalSheet, userMedalSheetBuilder(this.vm), {
        showClose: true,
        detents: [SheetSize.MEDIUM, SheetSize.LARGE], // 支持中等和全屏高度
        enableOutsideInteractive: false,
        preferType: this.vm.isTabletView ? SheetType.CENTER : SheetType.BOTTOM,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        backgroundColor: $r('app.color.start_window_background'),
        blurStyle: BlurStyle.BACKGROUND_THICK,
        title: {
          title: $r('app.string.MinePage_medal_center') // 确保 string.json 中有这个 key，或者使用 Resource
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