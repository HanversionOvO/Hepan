import { CommonConstant } from 'base_common';
import { MessagePageVM } from '../viewmodels/MessagePageVM';

export interface MessageNotifyCardItem {
  count: number,
  icon: Resource,
  iconColor: ResourceStr,
  cardTitle: ResourceStr,
  onCardClick: () => void
}

@ComponentV2
export struct MessageNotifyCard {
  @Param @Require vm: MessagePageVM;

  @Builder
  Card(messageCardModel: MessageNotifyCardItem) {
    Column({ space: CommonConstant.SmallContainerInnerPadding }) {
      Badge({
        count: messageCardModel.count,
        style: {
          badgeColor: CommonConstant.ErrorColor,
          badgeSize: CommonConstant.TextSizeLarge,
          fontSize: CommonConstant.TextSizeSmall,
          borderColor: CommonConstant.ErrorColor
        }
      }) {
        Column() {
          SymbolGlyph(messageCardModel.icon)
            .fontSize(CommonConstant.IconSizeNormal)
            .fontColor([$r('sys.color.font_on_primary')])
        }
        .padding(CommonConstant.NormalContainerInnerPadding)
        .borderRadius(CommonConstant.RadiusNormal)
        .backgroundColor(messageCardModel.iconColor)
      }

      Text(messageCardModel.cardTitle)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_secondary'))
    }
    .onClick(() => {
      messageCardModel.onCardClick();
    })
  }

  build() {
    Row() {
      ForEach(this.vm.messageNotifyCards, (messageCardModel: MessageNotifyCardItem) => {
        this.Card(messageCardModel)
      })
    }
    .width(CommonConstant.FullPercent)
    .padding({
      top: CommonConstant.LargeContainerTBPadding,
      bottom: CommonConstant.LargeContainerTBPadding
    })
    .borderRadius(CommonConstant.RadiusLarge)
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundColor($r('app.color.second_window_background'))
  }
}