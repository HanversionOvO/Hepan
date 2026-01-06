import { ReplyPageVM } from '../viewmodels/ReplyPageVM';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { CommonConstant } from 'base_common';

@ComponentV2
export struct ReplyPageImpl {
  @Local vm: ReplyPageVM = new ReplyPageVM();
  @Local maskOpacity: number = 0;
  @Local isShow: boolean = false;

  private playOpenAnim() {
    setTimeout(() => {
      // 1. 遮罩渐显
      this.maskOpacity = 1;
      this.isShow = true;

      // 3. 自动聚焦
      // this.vm.setInputFocus(true);
      // focusControl.requestFocus('reply_input');
    }, CommonConstant.AnimationDurationFast);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width(CommonConstant.FullPercent)
          .height(CommonConstant.FullPercent)
          .backgroundColor($r('app.color.mask_color'))
          .opacity(this.maskOpacity)
          .animation({
            duration: CommonConstant.AnimationDurationNormal,
            curve: CommonConstant.AnimationCurveNormal
          }) // 遮罩使用简单的线性渐变
        // .onClick(() => this.closeDialog())

        // 底部功能区，实现“@”、”表情“、选择图片功能

        // 评论输入区

        // 照片选择区

        // 顶部发送、取消按钮以及title
      }
    }
    .mode(NavDestinationMode.DIALOG)
    .onReady(() => {
      this.playOpenAnim();
    })
    .onShown(() => {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET)
    })
    .onHidden(() => {
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
    })
  }
}