import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, CommonConstant, MessageApi, RecentMessage, RouterUtil, StackEnum } from 'base_common';

@ObservedV2
export class ChatPageVM extends BaseVM {
  @Trace isHideNavBar: boolean = false;
  @Trace recentMessage: RecentMessage | undefined = undefined;

  async loadData() {
    if (this.recentMessage) {
      await MessageApi.getChat(this.recentMessage.toUserId, 0, 0);
    }
  }

  backPage() {
    AppUtil.getUIContext()
      .animateTo({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal },
        () => {
          RouterUtil.pop(undefined, false, StackEnum.MESSAGE);
        })
  }
}