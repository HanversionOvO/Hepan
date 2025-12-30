import { MinePageVM } from "../viewmodels/MinePageVM";
import { CommonConstant } from "base_common";

export interface UserProfileSheetItem {
  title: ResourceStr;
  value: ResourceStr | number;
}

export interface UserProfileFiltered {
  uid: number;
  username: string;
  group_title: string;
  credits: number;
  friends: number;
  threads: number;
  replies: number;
  digests: number;
  views: number;
  email?: string;
  register_time?: number;
  introduction?: string;
  custom_title?: string;
  signature?: string;
  signature_format?: string;
  online_time: number;
  last_visit?: number;
  last_activity?: number;
  last_post?: number;
  register_ip?: string;
  last_ip?: string;
}

@Builder
export function userProfileSheetBuilder(vm: MinePageVM) {
  UserProfileSheet({vm});
}

@ComponentV2
struct UserProfileSheet {
  @Param @Require vm: MinePageVM;
  @Local userProfileFiltered: Record<string, string>[] = [];
  
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
    .width("100%")
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
    .borderRadius({
      topLeft: index === 0 ? CommonConstant.RadiusNormal : 0,
      topRight: index === 0 ? CommonConstant.RadiusNormal : 0,
      bottomLeft: index === this.userProfileFiltered.length - 1 ? CommonConstant.RadiusNormal : 0,
      bottomRight: index === this.userProfileFiltered.length - 1 ? CommonConstant.RadiusNormal : 0
    })
    .backgroundColor($r('app.color.second_window_background'))
  }
  
  build() {
    Scroll() {
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
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding,
        top: CommonConstant.PageLRPadding,
        bottom: CommonConstant.PageLRPadding
      })
      .width("100%")
      
    }
  }
}