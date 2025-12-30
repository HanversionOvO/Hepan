import { MinePageVM } from '../viewmodels/MinePageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { CommonConstant, UserAvatarUtil } from 'base_common';
import { ResUtil } from '@pura/harmony-utils';
import { GlassButton } from 'base_ui';
import { UserStats, UserStatsModel } from './UserStats';
import { CardType, FeatureCard, FeatureCardModel } from './FeatureCard';

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
          if (!this.vm.isSticky) {
            Image(UserAvatarUtil.getAvatarUrl(this.vm.user?.user_summary?.uid!))
              .width(this.userAvatarSize)
              .height(this.userAvatarSize)
              .borderRadius(CommonConstant.RadiusRound)
              .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })
              .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
          } else {
            Image(UserAvatarUtil.getAvatarUrl(this.vm.user?.user_summary?.uid!))
              .width(this.userAvatarSize)
              .height(this.userAvatarSize)
              .borderRadius(CommonConstant.RadiusRound)
              .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })
              .opacity(0) // 占位隐藏
          }

          Column({ space: CommonConstant.NormalContainerTBPadding }) {
            // 修改：昵称部分
            if (!this.vm.isSticky) {
              Text(this.vm.user?.user_summary?.username)
                .fontSize(CommonConstant.TextSizeUltraLarge)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_on_primary'))
            } else {
              // 占位文本
              Text(this.vm.user?.user_summary?.username)
                .fontSize(CommonConstant.TextSizeUltraLarge)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Transparent)
            }

            Text(`${ResUtil.getStringSync($r('app.string.MinePage_uid'))}: ${this.vm.user?.user_summary?.uid}`)
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_on_primary'))
          }
          .alignItems(HorizontalAlign.Start)
        }

        Text(this.vm.user?.signature)
          .width(CommonConstant.FullPercent)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize(CommonConstant.TextSizeNormal)
          .margin({
            bottom: CommonConstant.NormalContainerTBPadding
          })
          .onClick(() => {

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