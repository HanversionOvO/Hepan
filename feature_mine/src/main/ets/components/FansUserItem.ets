import { CommonConstant, DateUtil, InterestingUser } from 'base_common';
import { CustomBadge, GlassButton } from 'base_ui';

export enum FansUserItemType {
  CARD,
  LIST
}

export interface FansUserItems {
  uid: number;
  username: string;
  signature?: ResourceStr;
  avatar: string;
  level?: string;
  date: number;
  isFriend?: boolean;
}

@ComponentV2
export struct FansUserItem {
  @Param user: FansUserItems | undefined = undefined;
  @Param recommendUser: InterestingUser | undefined = undefined;
  @Param type: FansUserItemType = FansUserItemType.LIST; // 卡片样式 或 列表样式
  @Param isShowDeleteButton: boolean = false;
  @Param deleteFriends: () => void = () => {
  };

  build() {
    if (this.type === FansUserItemType.CARD && this.recommendUser) {
      // === 横向推荐卡片样式 ===
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        Image(this.recommendUser.avatar)
          .height(CommonConstant.IconSizeLarge)
          .width(CommonConstant.IconSizeLarge)
          .borderRadius(CommonConstant.RadiusRound)
          .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
        Column({ space: CommonConstant.SmallContainerInnerPadding }) {
          Text(this.recommendUser.username)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(CommonConstant.TextSizeNormal)
          Text($r('app.string.FansUserItem_might_interested'))
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_tertiary'))
        }

        Button() {
          Text(this.recommendUser.isFriend ? $r('app.string.FansUserItem_is_friend') :
            $r('app.string.FansUserItem_add_friend'))
            .fontColor(this.recommendUser.isFriend ? $r('sys.color.font_tertiary') : $r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Bold)
            .fontSize(CommonConstant.TextSizeSmall)
        }
        .backgroundColor(this.recommendUser.isFriend ? $r('app.color.start_window_background') :
          CommonConstant.ThemeColor)
        .width(CommonConstant.IconSizeLarge * 3)
        .padding({
          top: CommonConstant.SmallContainerTBPadding,
          bottom: CommonConstant.SmallContainerTBPadding,
        })
      }
      .borderRadius(CommonConstant.RadiusLarge)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.second_window_background'))
      .padding({
        left: CommonConstant.LargeContainerLRPadding,
        right: CommonConstant.LargeContainerLRPadding,
        top: CommonConstant.LargeContainerTBPadding,
        bottom: CommonConstant.LargeContainerTBPadding,
      })
    } else if (this.user) {
      Row() {
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          Image(this.user.avatar)
            .height(CommonConstant.IconSizeLarge)
            .width(CommonConstant.IconSizeLarge)
            .borderRadius(CommonConstant.RadiusRound)
            .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
          Column({ space: CommonConstant.SmallContainerInnerPadding }) {
            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              Text(this.user.username)
                .fontWeight(FontWeight.Medium)
                .fontSize(CommonConstant.TextSizeNormal)
                .fontColor($r('sys.color.font_primary'))

              if (this.user.level) {
                CustomBadge({
                  text: this.user.level,
                  fontSize: CommonConstant.TextSizeUltraTiny,
                  bgColor: CommonConstant.ThemeColor,
                  textColor: $r('sys.color.font_on_primary'),
                  badgeBorderRadius: CommonConstant.RadiusTiny,
                  paddingLR: CommonConstant.SmallContainerInnerPadding,
                  paddingTB: CommonConstant.SmallContainerInnerPadding
                })
              }
            }

            if (this.user.signature) {
              Text(this.user.signature)
                .fontSize(CommonConstant.TextSizeNormal)
                .fontColor($r('sys.color.font_secondary'))
                .maxLines(1)
            }

            Text(DateUtil.getRelativeTime(this.user.date))
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_tertiary'))
          }.alignItems(HorizontalAlign.Start)
        }

        if (this.isShowDeleteButton) {
          GlassButton({
            text: $r('app.string.FansUserItem_delete_friend'),
            innerFontSize: CommonConstant.TextSizeSmall
          })
            .onClick(() => {
              if (this.deleteFriends) {
                this.deleteFriends();
              }
            })
        }
      }
      .width(CommonConstant.FullPercent)
      .padding({
        left: CommonConstant.NormalContainerLRPadding,
        right: CommonConstant.NormalContainerLRPadding,
        top: CommonConstant.NormalContainerTBPadding,
        bottom: CommonConstant.NormalContainerTBPadding,
      })
      .backgroundColor($r('app.color.second_window_background'))
      .borderRadius(CommonConstant.RadiusLarge)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}