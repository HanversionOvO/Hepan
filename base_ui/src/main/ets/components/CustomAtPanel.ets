import { ResUtil } from '@pura/harmony-utils';
import { AtUser, BaseVM, CommonConstant, ForumApi, UiState, UserAvatarUtil } from 'base_common';
import { StateLayout } from './StateLayout';

const TAG = '[CustomAtPanel]: ';

@ComponentV2
export struct CustomAtPanel {
  @Param @Require vm: BaseVM;
  @Event onAtUserClick: (user: AtUser) => void;
  @Local uiState: UiState = UiState.LOADING;
  @Local atUserList: AtUser[] = [];

  async aboutToAppear() {
    this.atUserList = await ForumApi.getAtUser();
    if (this.atUserList.length > 0) {
      this.uiState = UiState.SUCCESS;
    } else {
      this.uiState = UiState.EMPTY;
    }
  }

  @Builder
  AtUserBuilder(atUser: AtUser) {
    Row() {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        Image(UserAvatarUtil.getAvatarUrl(atUser.uid))
          .width(CommonConstant.IconSizeLarge)
          .height(CommonConstant.IconSizeLarge)
          .borderRadius(CommonConstant.RadiusRound)

        Column({ space: CommonConstant.SmallContainerInnerPadding }) {
          Text(atUser.username)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Medium)

          Text(`${ResUtil.getStringSync($r('app.string.CustomAtPanel_uid'))}: ${atUser.uid}`)
            .fontSize(CommonConstant.TextSizeSmall)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)
      }

      SymbolGlyph($r('sys.symbol.arrow_up'))
        .fontSize(CommonConstant.TextSizeNormal)
        .fontColor([$r('sys.color.font_secondary')])
    }
    .width(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Text($r('app.string.CustomAtPanel_title'))
        .width(CommonConstant.FullPercent)
        .fontSize(CommonConstant.TextSizeNormal)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)

      StateLayout({ uiState: this.uiState }) {
        List({ space: CommonConstant.NormalContainerInnerPadding }) {
          ForEach(this.atUserList, (atUser: AtUser) => {
            ListItem() {
              this.AtUserBuilder(atUser)
            }
            .onClick(() => {
              this.onAtUserClick(atUser);
            })
          }, (atUser: AtUser) => atUser.uid.toString())
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
        .padding({
          left: CommonConstant.NormalContainerLRPadding,
          right: CommonConstant.NormalContainerLRPadding
        })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width(CommonConstant.FullPercent)
    .height(this.vm.window.windowHeight * 0.4)
    .backgroundColor($r('app.color.second_window_background'))
    .borderRadius({
      topLeft: CommonConstant.RadiusUltraLarge,
      topRight: CommonConstant.RadiusUltraLarge
    })
    .padding({
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
  }
}