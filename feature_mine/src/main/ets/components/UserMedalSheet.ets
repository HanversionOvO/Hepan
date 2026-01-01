import { LottieView } from '@ohos/lottie-turbo';
import { ResUtil } from '@pura/harmony-utils';
import { CommonConstant, ToastUtil } from 'base_common';
import { Medal } from 'base_common/src/main/ets/api/models/UserModels';
import { MinePageVM } from '../viewmodels/MinePageVM';

@Builder
export function userMedalSheetBuilder(vm: MinePageVM) {
  UserMedalSheet({ vm: vm })
}

@ComponentV2
struct UserMedalSheet {
  @Param @Require vm: MinePageVM;
  @Local selectedMedal: Medal | null = null;
  // 修正 BASE_URL
  private readonly BASE_URL = 'https://bbs.uestc.edu.cn/static/image/common/';

  // 判断是否拥有勋章
  private isMedalOwned(medalId: number): boolean {
    return this.vm.user?.user_summary?.medals?.includes(medalId) ?? false;
  }

  // 1. 初始化时尝试选中（针对有缓存的情况）
  aboutToAppear(): void {
    if (this.vm.allMedals.length > 0) {
      this.selectedMedal = this.vm.allMedals[0];
    }
  }

  // 2. 监听数据变化（针对第一次加载，网络数据滞后返回的情况）
  @Monitor("vm.allMedals")
  onMedalsChange() {
    // 如果当前没有选中勋章，且数据列表不为空，默认选中第一个
    if (this.selectedMedal === null && this.vm.allMedals.length > 0) {
      this.selectedMedal = this.vm.allMedals[0];
    }
  }

  build() {
    Column() {
      // === 上部：预览详情区 ===
      // 使用显式动画容器，使高度变化平滑
      Column() {
        this.MedalDetailView()
      }
      .width(CommonConstant.FullPercent)
      .padding({ bottom: CommonConstant.NormalContainerTBPadding })
      .zIndex(1) // 保证投影在列表上方

      // === 下部：勋章列表区 ===
      if (this.vm.allMedals.length === 0) {
        this.LoadingView()
      } else {
        Grid() {
          ForEach(this.vm.allMedals, (medal: Medal) => {
            GridItem() {
              this.MedalGridItem(medal)
            }
            .onClick(() => {
              // 点击切换上方预览
              animateTo({ curve: Curve.FastOutSlowIn, duration: CommonConstant.AnimationDurationNormal }, () => {
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
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
  }

  // --- 详情预览视图 ---
  @Builder
  MedalDetailView() {
    if (this.selectedMedal) {
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        // 1. 顶部大图与光晕
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(CommonConstant.IconSizeUltraLarge * 3)
            .height(CommonConstant.IconSizeUltraLarge * 3)
            .fill(this.isMedalOwned(this.selectedMedal.id) ? CommonConstant.ThemeColor :
              $r('app.color.glass_background'))
            .opacity(0.1) // 淡淡的光晕背景
            .blur(20)

          Image(this.BASE_URL + this.selectedMedal.image_path)
            .width(CommonConstant.IconSizeUltraLarge * 2)
            .height(CommonConstant.IconSizeUltraLarge * 2)
            .objectFit(ImageFit.Contain)
        }
        .margin({ top: CommonConstant.NormalContainerTBPadding })

        // 2. 基本信息
        Text(this.selectedMedal.name)
          .fontSize(CommonConstant.TextSizeLarge)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))

        Text(this.selectedMedal.description || $r('app.string.MinePage_medal_no_desc'))
          .fontSize(CommonConstant.TextSizeNormal)
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 3. 属性标签
        Row({ space: CommonConstant.NormalContainerInnerPadding }) {
          this.InfoTag($r('sys.symbol.drop'),
            this.selectedMedal.price > 0 ? `${this.selectedMedal.price}` : $r('app.string.MinePage_medal_cant_buy'))

          if (this.selectedMedal.expiration_days > 0) {
            this.InfoTag($r('sys.symbol.clock'),
              `${this.selectedMedal.expiration_days}${ResUtil.getStringSync($r('app.string.MinePage_medal_day'))}`)
          }
        }

        // 4. 操作按钮
        // 只有查看自己主页时，且未拥有时，才显示购买
        if (this.vm.isMe && !this.isMedalOwned(this.selectedMedal.id)) {
          Button() {
            Text($r('app.string.MinePage_medal_buy'))
              .fontSize(CommonConstant.TextSizeNormal)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
          }
          .type(ButtonType.Capsule)
          .backgroundColor(CommonConstant.ThemeColor)
          .margin({
            top: CommonConstant.NormalContainerInnerPadding
          })
          .width('50%')
          .height(CommonConstant.IconSizeLarge)
          .onClick(() => {
            ToastUtil.showToast("购买功能开发中");
          })
        } else if (this.isMedalOwned(this.selectedMedal.id)) {
          // 已拥有状态展示
          Row({ space: CommonConstant.SmallContainerInnerPadding }) {
            SymbolGlyph($r('sys.symbol.checkmark_circle'))
              .fontColor([CommonConstant.ThemeColor])
              .fontSize(CommonConstant.TextSizeSmall)
            Text($r('app.string.MinePage_medal_has'))
              .fontColor(CommonConstant.ThemeColor)
              .fontSize(CommonConstant.TextSizeSmall)
          }
          .margin({ top: CommonConstant.NormalContainerInnerPadding })
          .padding({
            top: CommonConstant.SmallContainerTBPadding,
            bottom: CommonConstant.SmallContainerTBPadding,
            left: CommonConstant.SmallContainerLRPadding,
            right: CommonConstant.SmallContainerLRPadding
          })
          .backgroundColor($r('app.color.glass_background'))
          .borderRadius(CommonConstant.RadiusRound)
        }
      }
      .width(CommonConstant.FullPercent)
      .alignItems(HorizontalAlign.Center)
      .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
    }
  }

  // --- 列表加载中视图 ---
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

  // --- 网格单项视图 ---
  @Builder
  MedalGridItem(medal: Medal) {
    Column({ space: CommonConstant.SmallContainerInnerPadding }) {
      // 图片容器
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
      // 选中态：加粗边框
      .border({
        width: this.selectedMedal?.id === medal.id ? CommonConstant.BorderSizeLarge : 0,
        color: this.selectedMedal?.id === medal.id ? CommonConstant.ThemeColor : Color.Transparent
      })
      // 动画效果
      .scale({
        x: this.selectedMedal?.id === medal.id ? 1.05 : 1.0,
        y: this.selectedMedal?.id === medal.id ? 1.05 : 1.0
      })
      .animation({ duration: CommonConstant.AnimationDurationNormal })

      Text(medal.name)
        .fontSize(CommonConstant.TextSizeTiny)
        // 已拥有的文字深色，未拥有的浅色
        .fontColor(this.isMedalOwned(medal.id) ? $r('sys.color.font_secondary') : $r('sys.color.font_tertiary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
    }
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Center)
  }

  // --- 通用标签组件 ---
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