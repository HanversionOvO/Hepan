import { LottieView } from '@ohos/lottie-turbo';
import { AppUtil, ResUtil } from '@pura/harmony-utils';
import { CommonConstant, createEmptyMedal, Medal, ToastUtil } from 'base_common';
import { MinePageVM } from '../viewmodels/MinePageVM';

@Builder
export function userMedalSheetBuilder(vm: MinePageVM) {
  UserMedalSheet({ vm: vm })
}

@ComponentV2
struct UserMedalSheet {
  @Param @Require vm: MinePageVM;
  @Local selectedMedal: Medal = createEmptyMedal();
  // 新增：控制预览区是否为紧凑模式
  @Local isCompact: boolean = false;
  // 新增：列表滚动控制器
  @Local scroller: Scroller = new Scroller();
  private readonly BASE_URL = 'https://bbs.uestc.edu.cn/static/image/common/';

  private isMedalOwned(medalId: number): boolean {
    return this.vm.user?.user_summary?.medals?.includes(medalId) ?? false;
  }

  aboutToAppear(): void {
    if (this.vm.allMedals.length > 0) {
      this.selectedMedal = this.vm.allMedals[0];
    }
  }

  @Monitor("vm.allMedals")
  onMedalsChange() {
    if (this.vm.allMedals.length > 0) {
      this.selectedMedal = this.vm.allMedals[0];
    }
  }

  // 新增：处理滚动事件，参考 FansUserSection 逻辑
  private handleScroll(yOffset: number, scrollState: ScrollState) {
    if (scrollState === ScrollState.Scroll) {
      // 手指向上滑是正值（内容下移），进入紧凑模式
      if (yOffset > CommonConstant.ScrollAnimationThreshold && !this.isCompact) {
        AppUtil.getUIContext()
          .animateTo({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal },
            () => {
              this.isCompact = true;
            })
      }
      // 手指向下滑是负值（内容上移），恢复展开模式
      else if (yOffset < -CommonConstant.ScrollAnimationThreshold && this.isCompact) {
        AppUtil.getUIContext()
          .animateTo({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal },
            () => {
              this.isCompact = false;
            })
      }
    }
  }

  build() {
    Column() {
      // === 上部：预览详情区 ===
      Column() {
        this.MedalDetailView()
      }
      .width(CommonConstant.FullPercent)
      // 移除原有的底部 padding，由内部布局控制
      .padding({ bottom: this.isCompact ? 0 : CommonConstant.NormalContainerTBPadding })
      .zIndex(1)

      // === 下部：勋章列表区 ===
      if (this.vm.allMedals.length === 0) {
        this.LoadingView()
      } else {
        // 绑定 scroller
        Grid(this.scroller) {
          ForEach(this.vm.allMedals, (medal: Medal) => {
            GridItem() {
              this.MedalGridItem(medal)
            }
            .onClick(() => {
              AppUtil.getUIContext()
                .animateTo({ curve: Curve.FastOutSlowIn, duration: CommonConstant.AnimationDurationNormal }, () => {
                  this.selectedMedal = medal;
                })
            })
          }, (item: Medal) => item.id.toString())
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(CommonConstant.NormalContainerInnerPadding)
        .columnsGap(CommonConstant.NormalContainerInnerPadding)
        .padding(CommonConstant.NormalContainerLRPadding)
        .width(CommonConstant.FullPercent)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .margin({ top: CommonConstant.NormalContainerTBPadding })
        // 绑定滚动事件
        .onWillScroll((yOffset, state) => {
          this.handleScroll(yOffset, state);
        })
        // 触顶时强制展开
        .onReachStart(() => {
          AppUtil.getUIContext()
            .animateTo({ curve: CommonConstant.AnimationCurveSpring, duration: CommonConstant.AnimationDurationNormal },
              () => {
                this.isCompact = false;
              })
        })
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }

  // --- 详情预览视图 ---
  @Builder
  MedalDetailView() {
    if (this.selectedMedal) {
      // 增加动画属性，使高度变化更平滑
      Column({ space: this.isCompact ? 0 : CommonConstant.NormalContainerInnerPadding }) {
        // 1. 顶部大图与光晕 (紧凑模式下变小)
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(this.isCompact ? CommonConstant.IconSizeLarge : CommonConstant.IconSizeUltraLarge * 3)
            .height(this.isCompact ? CommonConstant.IconSizeLarge : CommonConstant.IconSizeUltraLarge * 3)
            .fill(this.isMedalOwned(this.selectedMedal.id) ? CommonConstant.ThemeColor :
              $r('app.color.glass_background'))
            .opacity(0.1)
            .blur(20)
            .animation({ duration: CommonConstant.AnimationDurationNormal }) // 显式动画

          Image(this.BASE_URL + this.selectedMedal.image_path)
            .width(this.isCompact ? CommonConstant.IconSizeLarge : CommonConstant.IconSizeUltraLarge * 2)
            .height(this.isCompact ? CommonConstant.IconSizeLarge : CommonConstant.IconSizeUltraLarge * 2)
            .objectFit(ImageFit.Contain)
            .animation({ duration: CommonConstant.AnimationDurationNormal }) // 显式动画
        }
        .margin({ top: CommonConstant.NormalContainerTBPadding })

        // 2. 基本信息
        Text(this.selectedMedal.name)
          .fontSize(this.isCompact ? CommonConstant.TextSizeNormal : CommonConstant.TextSizeLarge)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .margin({
            top: this.isCompact ? CommonConstant.NormalContainerTBPadding : 0,
            bottom: this.isCompact ? CommonConstant.NormalContainerTBPadding : 0
          })

        // 3. 详细信息区 (描述、标签、按钮) - 紧凑模式下隐藏
        if (!this.isCompact) {
          Column({ space: CommonConstant.NormalContainerInnerPadding }) {
            Text(this.selectedMedal.description || $r('app.string.MinePage_medal_no_desc'))
              .fontSize(CommonConstant.TextSizeNormal)
              .fontColor($r('sys.color.font_secondary'))
              .textAlign(TextAlign.Center)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))

            Row({ space: CommonConstant.NormalContainerInnerPadding }) {
              this.InfoTag($r('sys.symbol.drop'),
                this.selectedMedal.price > 0 ? `${this.selectedMedal.price}` : $r('app.string.MinePage_medal_cant_buy'))

              if (this.selectedMedal.expiration_days > 0) {
                this.InfoTag($r('sys.symbol.clock'),
                  `${this.selectedMedal.expiration_days}${ResUtil.getStringSync($r('app.string.MinePage_medal_day'))}`)
              }
            }
            .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))

            // 操作按钮
            if (this.vm.isMe && !this.isMedalOwned(this.selectedMedal.id)) {
              Button() {
                Text($r('app.string.MinePage_medal_buy'))
                  .fontSize(CommonConstant.TextSizeNormal)
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontWeight(FontWeight.Medium)
              }
              .type(ButtonType.Capsule)
              .backgroundColor(CommonConstant.ThemeColor)
              .width('50%')
              .height(CommonConstant.IconSizeLarge)
              .onClick(() => {
                ToastUtil.showToast("购买功能开发中");
              })
              .transition(TransitionEffect.move(TransitionEdge.BOTTOM).combine(TransitionEffect.OPACITY))
            } else if (this.isMedalOwned(this.selectedMedal.id)) {
              Row({ space: CommonConstant.SmallContainerInnerPadding }) {
                SymbolGlyph($r('sys.symbol.checkmark_circle'))
                  .fontColor([CommonConstant.ThemeColor])
                  .fontSize(CommonConstant.TextSizeSmall)
                Text($r('app.string.MinePage_medal_has'))
                  .fontColor(CommonConstant.ThemeColor)
                  .fontSize(CommonConstant.TextSizeSmall)
              }
              .padding({
                top: CommonConstant.SmallContainerTBPadding,
                bottom: CommonConstant.SmallContainerTBPadding,
                left: CommonConstant.SmallContainerLRPadding,
                right: CommonConstant.SmallContainerLRPadding
              })
              .backgroundColor($r('app.color.glass_background'))
              .borderRadius(CommonConstant.RadiusRound)
              .transition(TransitionEffect.OPACITY)
            }
          }
          .width(CommonConstant.FullPercent)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width(CommonConstant.FullPercent)
      .alignItems(HorizontalAlign.Center)
      .animation({ duration: CommonConstant.AnimationDurationNormal, curve: Curve.FastOutSlowIn }) // 容器高度变化的平滑动画
    }
  }

  @Builder
  LoadingView() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      LottieView({
        lottieId: 'loading_medal',
        path: $rawfile('loading_lottie.json')
      })
        .height(CommonConstant.LottieSizeSmall)
      Text($r('app.string.StateLayout_loading'))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize(CommonConstant.TextSizeNormal)
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  MedalGridItem(medal: Medal) {
    Column({ space: CommonConstant.SmallContainerInnerPadding }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.BASE_URL + medal.image_path)
          .width(CommonConstant.IconSizeLarge)
          .height(CommonConstant.IconSizeLarge)
          .objectFit(ImageFit.Contain)
          .opacity(this.isMedalOwned(medal.id) ? 1.0 : 0.4)
          .grayscale(this.isMedalOwned(medal.id) ? 0 : 0.9)
      }
      .width(CommonConstant.IconSizeLarge * 2)
      .height(CommonConstant.IconSizeLarge * 2)
      .backgroundColor($r('app.color.glass_background'))
      .borderRadius(CommonConstant.RadiusNormal)
      .border({
        width: this.selectedMedal?.id === medal.id ? CommonConstant.BorderSizeLarge : 0,
        color: this.selectedMedal?.id === medal.id ? CommonConstant.ThemeColor : Color.Transparent
      })
      .scale({
        x: this.selectedMedal?.id === medal.id ? 1.05 : 1.0,
        y: this.selectedMedal?.id === medal.id ? 1.05 : 1.0
      })
      .animation({ duration: CommonConstant.AnimationDurationNormal })

      Text(medal.name)
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor(this.isMedalOwned(medal.id) ? $r('sys.color.font_secondary') : $r('sys.color.font_tertiary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
    }
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  InfoTag(icon: Resource, text: ResourceStr) {
    Row({ space: CommonConstant.SmallContainerInnerPadding }) {
      SymbolGlyph(icon)
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor([$r('sys.color.font_secondary')])
      Text(text)
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor($r('sys.color.font_secondary'))
    }
    .padding(CommonConstant.SmallContainerTBPadding)
    .borderRadius(CommonConstant.RadiusSmall)
    .backgroundColor($r('app.color.glass_background'))
  }
}
