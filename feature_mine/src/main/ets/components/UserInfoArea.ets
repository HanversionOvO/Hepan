import { MinePageVM } from '../viewmodels/MinePageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { CommonConstant, UserAvatarUtil, TransitionMap } from 'base_common';
import { ResUtil } from '@pura/harmony-utils';
import { GlassButton } from 'base_ui';
import { UserStats, UserStatsModel } from './UserStats';
import { CardType, FeatureCard, FeatureCardModel } from './FeatureCard';
import { signatureSheetBuilder } from './SignatureSheet';
import { userProfileSheetBuilder } from './UserProfileSheet';

@ComponentV2
export struct UserInfoArea {
  @Param @Require vm: MinePageVM;
  @Local userAvatarSize: number = 96;

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
          Image(UserAvatarUtil.getAvatarUrl(this.vm.user?.user_summary?.uid!))
            .width(this.userAvatarSize)
            .height(this.userAvatarSize)
            .borderRadius(CommonConstant.RadiusRound)
            .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })

          Column({ space: CommonConstant.NormalContainerTBPadding }) {
            // 修改：昵称部分
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
            this.vm.isShowSignatureSheet = true;
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
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width(this.vm.isTabletView ? CommonConstant.BelowHalfPercent : CommonConstant.FullPercent)
      .alignItems(HorizontalAlign.Start)

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
    }
    .width(CommonConstant.FullPercent)
    .padding({
      top: CommonConstant.TopBarHeight + this.vm.window.windowTopPadding
    })
  }
}