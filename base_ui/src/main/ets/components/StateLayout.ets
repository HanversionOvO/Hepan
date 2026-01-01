import { LottieView } from '@ohos/lottie-turbo';
import { CommonConstant, UiState } from 'base_common'; // 确保引用到你的 BaseVM 中的枚举
import { GlassButton } from './GlassButton';

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
          LottieView({
            lottieId: 'loading',
            path: $rawfile('loading_lottie.json')
          })
            .height(CommonConstant.LottieSizeSmall)
          Text($r('app.string.StateLayout_loading'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(CommonConstant.TextSizeNormal)
        }
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .transition(CommonConstant.FADE_TRANSITION)
      }

      // 2. 错误状态
      else if (this.uiState === UiState.ERROR) {
        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          LottieView({
            lottieId: 'error',
            path: $rawfile('error_lottie.json')
          })
            .height(CommonConstant.LottieSizeNormal)
          Text($r('app.string.StateLayout_error'))
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(CommonConstant.TextSizeNormal)
          GlassButton({
            symbol: $r('sys.symbol.arrow_clockwise'),
            text: $r('app.string.StateLayout_retry'),
          })
        }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.Center)
      }

      // 3. 空数据状态
      else if (this.uiState === UiState.EMPTY) {
        Column({ space: 10 }) {
          Column({ space: CommonConstant.NormalContainerInnerPadding }) {
            LottieView({
              lottieId: 'empty',
              path: $rawfile('empty_lottie.json')
            })
              .height(CommonConstant.LottieSizeNormal)
            Text(this.emptyStr)
              .fontColor($r('sys.color.font_secondary'))
              .fontSize(CommonConstant.TextSizeNormal)
          }
        }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .justifyContent(FlexAlign.Center)
      }

      // 4. 成功状态（显示实际内容）
      else if (this.uiState === UiState.SUCCESS) {
        Column() {
          this.content()
        }
        .width(CommonConstant.FullPercent)
        .height(CommonConstant.FullPercent)
        .transition(CommonConstant.CONF_TRANSITION)
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }
}