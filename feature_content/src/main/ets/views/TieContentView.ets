import { CommonConstant, TieRow, TransitionMap, UiState } from 'base_common';
import { CustomFloatNavTitle, CustomTabBar, StateLayout } from 'base_ui';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { ImageSwiper } from '../components/ImageSwiper';
import { UserInfoArea } from '../components/UserInfoArea';
import { TieDetailFooter } from '../components/TieDetailFooter';
import { TieDetailComment } from '../components/TieDetailComment';
import { ResUtil } from '@pura/harmony-utils';
import { ImagePlacer } from '../components/ImagePlacer';
import { TieContentRender } from '../components/TieContentRender';
import { CommentCard } from '../components/CommentCard';

@ComponentV2
export struct TieContentView {
  @Param @Require vm: TieContentPageVM;
  @Local sideNavWidth: number = 380;
  @Local swiperHeight: number = 300;

  @Builder
  TieTitle(color: ResourceColor, isNavBar: boolean) {
    Text(this.vm.tieThread.subject || this.vm.tieSummary?.subject || '')
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
  ArticleSkeleton() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      ForEach([1, 2, 3, 4, 5], (index: number) => {
        Row()
          .width(index % 2 === 0 ? CommonConstant.FullPercent : CommonConstant.AboveHalfPercent)
          .height(CommonConstant.TextSizeNormal)
          .backgroundColor($r('sys.color.font_tertiary'))
          .opacity(0.1)
          .borderRadius(CommonConstant.RadiusTiny)
      })
    }
    .width(CommonConstant.FullPercent)
    .alignItems(HorizontalAlign.Start)
    .borderRadius(CommonConstant.RadiusLarge)
    .padding({ top: CommonConstant.NormalContainerInnerPadding })
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

        if (this.vm.commentLoadingState === UiState.LOADING && !this.vm.tieTopic?.message) {
          this.ArticleSkeleton()
        } else if (this.vm.tieTopic?.message) {
          TieContentRender({
            message: this.vm.tieTopic.message,
            format: this.vm.tieTopic.format,
            attachments: this.vm.tieTopic.attachments || []
          })
            .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
        }

        if (this.vm.tieTopic?.post_id) {
          TieDetailFooter({ vm: this.vm })
        }

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

  @Builder
  CommentContent() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: CommonConstant.NormalContainerInnerPadding }) {
        if (!this.vm.isTabletView) {
          Divider()
            .color($r('sys.color.font_tertiary'))
            .opacity(0.3)
            .strokeWidth(CommonConstant.BorderSizeLarge)
            .margin({
              top: CommonConstant.NormalContainerInnerPadding,
              bottom: CommonConstant.NormalContainerInnerPadding
            })
        } else {
          Column()
            .width(CommonConstant.FullPercent)
            .height(this.vm.window.windowTopPadding + CommonConstant.NormalContainerInnerPadding)
        }

        Flex({
          direction: this.vm.isTabletView ? FlexDirection.Row : FlexDirection.Column,
          justifyContent: this.vm.isTabletView ? FlexAlign.SpaceBetween : undefined,
          alignItems: ItemAlign.Center,
          space: {
            main: this.vm.isTabletView ? LengthMetrics.vp(0) :
              LengthMetrics.vp(CommonConstant.NormalContainerInnerPadding)
          }
        }) {

          Text((this.vm.tieThread.replies ?? 0) + " " +
          ResUtil.getStringSync($r('app.string.TieContentPage_comment_num')))
            .fontSize(CommonConstant.TextSizeLarge)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_secondary'))
            .layoutWeight(this.vm.isTabletView ? 1 : "auto")
            .width(this.vm.isTabletView ? "auto" : CommonConstant.FullPercent)

          CustomTabBar({
            vm: this.vm,
            tabItems: this.vm.sortMethods,
            currentIndex: this.vm.currentSort,
            changeTab: (index: number) => {
              this.vm.changeSort(index);
            },
            alignMode: this.vm.isTabletView ? FlexAlign.Start : FlexAlign.Center,
            isGlassStyle: true,
            isMax: false
          })
        }
        .width(CommonConstant.FullPercent)

        StateLayout({
          uiState: this.vm.commentLoadingState
        }) {
          Column({ space: CommonConstant.NormalContainerInnerPadding }) {
            ForEach(this.vm.tieComments || [], (comment: TieRow) => {
              CommentCard({
                tieComment: comment,
                authorID: this.vm.tieThread.author_id,
                threadId: this.vm.tieThread.thread_id
              })
                .id(this.vm.getCommentComponentId(comment.post_id))
            }, (comment: TieRow) => comment.post_id.toString())

            Text("- THE END -")
              .width(CommonConstant.FullPercent)
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_tertiary'))
              .textAlign(TextAlign.Center)
              .padding({
                bottom: this.vm.isTabletView ? this.vm.window.windowBottomPadding :
                  CommonConstant.NormalContainerTBPadding * 6 + this.vm.window.windowBottomPadding
              })
          }
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
                  if (this.vm.tieSummary?.summary_attachments && this.vm.tieSummary.summary_attachments.length > 0) {
                    ImageSwiper({ vm: this.vm, swiperHeight: this.swiperHeight })
                  } else {
                    ImagePlacer({ vm: this.vm, swiperHeight: this.swiperHeight })
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
                  this.vm.handleScroll(this.swiperHeight);
                }
              })
              .onScroll(() => {
                if (this.vm.isTabletView) {
                  this.vm.isReachEnd = this.vm.detailScroller.isAtEnd();
                }
              })

              if (this.vm.isTabletView && this.vm.tieTopic?.post_id) {
                TieDetailComment({ vm: this.vm, sideNavWidth: this.sideNavWidth })
              }
            }
            .height(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)

            if (this.vm.isTabletView) {
              Scroll(this.vm.commentScroller) {
                Column() {
                  this.CommentContent()
                }
                .width("auto")
                .justifyContent(FlexAlign.Start)
              }
              .height(CommonConstant.FullPercent)
              .layoutWeight(1)
              .align(Alignment.TopStart)
              .scrollBar(BarState.Off)
              .id(TieContentPageVM.COMMENT_SCROLL_ID)
              .nestedScroll({
                scrollForward: NestedScrollMode.SELF_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST,
              })
              .onReachEnd(() => {
                this.vm.loadMore();
              })
            } else {
              // 手机模式：直接渲染内容，由外层 outerPageScroller 负责滚动
              Column() {
                this.CommentContent()
              }
              .width(CommonConstant.FullPercent)
            }
          }
          .height(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)
        }
        .height(CommonConstant.FullPercent)
        .scrollable(this.vm.isTabletView ? ScrollDirection.None : ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .id(TieContentPageVM.OUTER_SCROLL_ID)
        .onDidScroll(() => {
          if (!this.vm.isTabletView) {
            this.vm.handleScroll(this.swiperHeight);
          }
        })
        .onReachEnd(() => {
          if (!this.vm.isTabletView) {
            this.vm.loadMore();
          }
        })

        if (!this.vm.isTabletView && this.vm.tieTopic?.post_id) {
          Column() {
            TieDetailComment({ vm: this.vm, sideNavWidth: this.sideNavWidth })
          }
          .width(CommonConstant.FullPercent)
          .position({ bottom: CommonConstant.NormalContainerTBPadding })
          .hitTestBehavior(HitTestMode.Transparent)
        }
      }
    }
    .onRefreshing(() => {
      this.vm.refresh();
    })
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.start_window_background'))
  }
}
