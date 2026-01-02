import { AppUtil } from '@pura/harmony-utils';
import { BaseVM, Chat, CommonConstant, MessageApi, RecentMessage, RouterUtil, StackEnum } from 'base_common';

const TAG = '[ChatPageVM]: ';

@ObservedV2
export class ChatPageVM extends BaseVM {
  @Trace isHideNavBar: boolean = false;
  @Trace recentMessage: RecentMessage | undefined = undefined;
  @Trace richEditorController: RichEditorController = new RichEditorController();
  @Trace chats: Chat[] = [];

  async loadData() {
    if (this.recentMessage) {
      const chats: Chat[] = await MessageApi.getChat(this.recentMessage.toUserId, 0, 0);
      this.chats = chats;
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