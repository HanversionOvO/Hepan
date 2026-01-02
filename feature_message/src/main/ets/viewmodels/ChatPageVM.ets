import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { BaseVM, Chat, CommonConstant, MessageApi, RecentMessage, RouterUtil, StackEnum } from 'base_common';

const TAG = '[ChatPageVM]: ';

@ObservedV2
export class ChatPageVM extends BaseVM {
  @Trace isHideNavBar: boolean = false;
  @Trace recentMessage: RecentMessage | undefined = undefined;

  async loadData() {
    if (this.recentMessage) {
      const chat: Chat[] = await MessageApi.getChat(this.recentMessage.toUserId, 0, 0);
      LogUtil.debug(TAG, JSON.stringify(chat));
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