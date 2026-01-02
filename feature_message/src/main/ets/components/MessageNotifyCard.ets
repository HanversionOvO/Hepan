import { CommonConstant, TransitionMap } from 'base_common';
import { MessagePageVM } from '../viewmodels/MessagePageVM';

@ObservedV2
export class MessageNotifyCardItem {
  type: 'at' | 'post' | 'system' = 'at';
  @Trace count: number = 0;
  icon: Resource = $r('sys.symbol.at');
  iconColor: ResourceColor = CommonConstant.ThemeColor;
  cardTitle: ResourceStr = '';
  onCardClick: () => void = () => {
  };

  constructor(
    type: 'at' | 'post' | 'system',
    count: number,
    icon: Resource,
    iconColor: ResourceColor,
    cardTitle: ResourceStr,
    onCardClick: () => void
  ) {
    this.type = type;
    this.count = count;
    this.icon = icon;
    this.iconColor = iconColor;
    this.cardTitle = cardTitle;
    this.onCardClick = onCardClick;
  }
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
        .padding(CommonConstant.SmallContainerTBPadding)
        .borderRadius(CommonConstant.RadiusLarge)
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