import { MinePageVM } from '../viewmodels/MinePageVM';
import { CommonConstant } from 'base_common';

export interface UserProfileSheetItem {
  title: ResourceStr;
  value: ResourceStr | number;
}

export interface UserProfileMapping {
  val: string | number | undefined;
  suffix: ResourceStr;
  isDate: boolean;
}

@Builder
export function userProfileSheetBuilder(vm: MinePageVM) {
  UserProfileSheet({ vm });
}

@ComponentV2
struct UserProfileSheet {
  @Param @Require vm: MinePageVM;
  @Local userProfileFiltered: UserProfileSheetItem[] = [];

  aboutToAppear(): void {
    this.userProfileFiltered = this.vm.getFilteredUserProfile();
  }

  @Builder
  userInfoItem(index: number, title: ResourceStr, content: string) {
    Row() {
      Text(title)
        .fontSize(CommonConstant.TextSizeNormal)
        .fontWeight(FontWeight.Bold)

      Text(content)
        .fontSize(CommonConstant.TextSizeSmall)
        .fontColor($r('sys.color.font_secondary'))
    }
    .width(CommonConstant.FullPercent)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(CommonConstant.NormalContainerLRPadding)
    .backgroundColor($r('app.color.second_window_background'))
  }

  build() {
    Column() {
      List() {
        ForEach(this.userProfileFiltered, (item: UserProfileSheetItem, index: number) => {
          ListItem() {
            this.userInfoItem(index, item.title, item.value.toString())
          }
        }, (item: UserProfileSheetItem, index: number) => index.toString())

        if (!this.vm.isTabletView) {
          ListItem()
            .height(this.vm.window.windowBottomPadding)
        }
      }
      .width(CommonConstant.FullPercent)
      .height(CommonConstant.FullPercent)
      .borderRadius(CommonConstant.RadiusNormal)
      .scrollBar(BarState.Off)
    }
    .padding({
      left: CommonConstant.PageLRPadding,
      right: CommonConstant.PageLRPadding,
      bottom: CommonConstant.PageLRPadding
    })
  }
}