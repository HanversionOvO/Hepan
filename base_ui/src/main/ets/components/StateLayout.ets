import { CommonConstant, UiState } from 'base_common'; // 确保引用到你的 BaseVM 中的枚举

@ComponentV2
export struct StateLayout {
  @Param @Require uiState: UiState; // 接收 VM 的状态
  @BuilderParam content: () => void; // 成功时显示的内容
  @Param onRetry: () => void = () => {
  }; // 点击错误页面的重试回调
  @Param emptyStr: ResourceStr = $r('app.string.StateLayout_empty'); // 可配置的空文案

  build() {
    Stack() {
      // 1. 加载中状态
      if (this.uiState === UiState.LOADING) {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          LoadingProgress()
            .width(CommonConstant.IconSizeUltraLarge)
            .height(CommonConstant.IconSizeUltraLarge)
            .color(CommonConstant.ThemeColor) // 假设有主题色
          Text($r('app.string.StateLayout_loading'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(CommonConstant.TextSizeNormal)
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      // 2. 错误状态
      else if (this.uiState === UiState.ERROR) {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          Image($r('sys.media.ohos_ic_public_fail')) // 使用系统图标或自定义
            .width(CommonConstant.TextSizeUltraLarge)
            .height(64)
            .fillColor($r('sys.color.ohos_id_color_text_tertiary'))
          Text('加载失败，请重试')
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(14)
          Button('重试')
            .onClick(() => {
              this.onRetry();
            })
            .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }

      // 3. 空数据状态
      else if (this.uiState === UiState.EMPTY) {
        Column({ space: 10 }) {
          Image($r('sys.media.ohos_ic_public_cancel')) // 使用系统图标或自定义
            .width(64)
            .height(64)
            .fillColor($r('sys.color.ohos_id_color_text_tertiary'))
          Text(this.emptyStr)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(14)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }

      // 4. 成功状态（显示实际内容）
      else if (this.uiState === UiState.SUCCESS) {
        this.content()
      }
    }
    .width('100%')
    .height('100%')
  }
}