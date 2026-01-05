import { CommonConstant, TransitionMap } from 'base_common';
import { CustomFloatNavTitle, CustomMarkdown } from 'base_ui';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { ImageSwiper } from '../components/ImageSwiper';
import { UserInfoArea } from '../components/UserInfoArea';
import { TieDetailFooter } from '../components/TieDetailFooter';
import { TieDetailComment } from '../components/TieDetailComment';

@ComponentV2
export struct TieContentView {
  @Param @Require vm: TieContentPageVM;
  @Local sideNavWidth: number = 380;

  @Builder
  TieTitle(color: ResourceColor, isNavBar: boolean) {
    Text(this.vm.tieSummary?.subject)
      .fontSize(CommonConstant.TextSizeLarge)
      .fontColor(color)
      .fontWeight(FontWeight.Bold)
      .maxLines(isNavBar ? 1 : -1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .geometryTransition(
        (isNavBar || !this.vm.isSticky) ? TransitionMap.TieDetailPageTitle : null,
        { follow: true }
      )
      .width(isNavBar ? "auto" : CommonConstant.FullPercent)
      .textAlign(TextAlign.Start)
      .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
  }

  @Builder
  TieDetailContent() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .backgroundColor($r('app.color.start_window_background'))
        .offset({
          top: -CommonConstant.NormalContainerTBPadding
        })
        .borderRadius({
          topLeft: CommonConstant.RadiusUltraLarge,
          topRight: CommonConstant.RadiusUltraLarge,
        })
        .height(CommonConstant.RadiusUltraLarge * 2)
        .width(CommonConstant.FullPercent)

      Column({ space: CommonConstant.LargeContainerInnerPadding }) {
        if (!this.vm.isSticky) {
          this.TieTitle($r('sys.color.font_primary'), false)
        } else {
          Column() {
            this.TieTitle($r('sys.color.font_primary'), false)
          }
          .width(CommonConstant.FullPercent)
          .visibility(Visibility.Hidden)
        }

        UserInfoArea({ vm: this.vm })

        CustomMarkdown({
          content: this.vm.tieDetail?.rows[0].message
        })

        TieDetailFooter({ vm: this.vm })

        if (this.vm.isTabletView) {
          Column()
            .height(CommonConstant.IconSizeLarge + CommonConstant.SmallContainerInnerPadding * 2 +
            this.vm.window.windowBottomPadding)
            .width(CommonConstant.FullPercent)
        }
      }
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding,
      })
    }
    .width(CommonConstant.FullPercent)
  }

  build() {
    Refresh({ refreshing: $$this.vm.isRefreshingDetail }) {
      Stack({ alignContent: Alignment.Top }) {
        CustomFloatNavTitle({
          vm: this.vm,
          isFloating: !this.vm.isSticky,
          buttons: this.vm.titleButtons,
          content: () => {
            if (this.vm.isSticky) {
              this.TieTitle($r('sys.color.font_primary'), true)
            }
          }
        })
          .width(this.vm.isTabletView ? this.sideNavWidth : CommonConstant.FullPercent)
          .position({
            left: 0
          })
          .zIndex(5)

        Scroll(this.vm.outerPageScroller) {
          Flex({
            direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.Column,
            space: {
              main: LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding)
            },
            alignItems: ItemAlign.Start
          }) {
            Stack({ alignContent: Alignment.Bottom }) {
              Scroll(this.vm.detailScroller) {
                Column() {
                  if (this.vm.tieSummary?.summary_attachments) {
                    ImageSwiper({ vm: this.vm })
                      .geometryTransition(TransitionMap.TieDetailImages)
                  }
                  this.TieDetailContent()
                }
                .width(this.vm.isTabletView ? this.sideNavWidth : CommonConstant.FullPercent)
                .justifyContent(FlexAlign.Start)
              }
              .height(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)
              .align(Alignment.TopStart)
              .scrollBar(BarState.Off)
              .nestedScroll({
                scrollForward: this.vm.isTabletView ? NestedScrollMode.SELF_FIRST : NestedScrollMode.PARENT_FIRST,
                scrollBackward: this.vm.isTabletView ? NestedScrollMode.SELF_FIRST : NestedScrollMode.PARENT_FIRST,
              })
              .onDidScroll(() => {
                if (this.vm.isTabletView) {
                  // this.handleScroll();
                }
              })
              .onScroll(() => {
                if (this.vm.isTabletView) {
                  this.vm.isReachEnd = this.vm.detailScroller.isAtEnd();
                }
              })

              if (this.vm.isTabletView) {
                TieDetailComment({ vm: this.vm, sideNavWidth: this.sideNavWidth })
              }
            }
            .height(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)

            Scroll(this.vm.commentScroller) {
              Column() {
                // this.CommentContent()
              }
              .width(this.vm.isTabletView ? "auto" : CommonConstant.FullPercent)
              .justifyContent(FlexAlign.Start)
            }
            .height(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)
            .layoutWeight(this.vm.isTabletView ? 1 : 0)
            .align(Alignment.TopStart)
            .scrollBar(BarState.Off)
            .nestedScroll({
              scrollForward: this.vm.isTabletView ? NestedScrollMode.SELF_FIRST : NestedScrollMode.PARENT_FIRST,
              scrollBackward: this.vm.isTabletView ? NestedScrollMode.SELF_FIRST : NestedScrollMode.PARENT_FIRST,
            })
          }
          .height(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)
        }
        .height(CommonConstant.FullPercent)
        .scrollable(this.vm.isTabletView ? ScrollDirection.None : ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .onDidScroll(() => {
          if (!this.vm.isTabletView) {
            // this.handleScroll();
          }
        })

        if (!this.vm.isTabletView) {
          Column() {
            TieDetailComment({ vm: this.vm, sideNavWidth: this.sideNavWidth })
          }
          .width(CommonConstant.FullPercent)
          .position({ bottom: CommonConstant.NormalContainerTBPadding })
          .hitTestBehavior(HitTestMode.Transparent)
        }
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.start_window_background'))
  }
}