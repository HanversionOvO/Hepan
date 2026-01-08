import { CollectionUser, CommonConstant, TransitionMap, UserAvatarUtil } from 'base_common';
import { CustomFloatNavTitle } from 'base_ui';
import { CollectionContentPageVM } from '../viewmodels/CollectionContentPageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { ResUtil } from '@pura/harmony-utils';

@ComponentV2
export struct CollectionContentView {
  @Param @Require vm: CollectionContentPageVM;
  @Local sideNavWidth: number = 380;
  @Local decoCardSize: number = 108;

  @Builder
  CollectionTitle(color: ResourceColor, isNavBar: boolean) {
    Text(this.vm.collection?.title)
      .fontSize(CommonConstant.TextSizeLarge)
      .fontColor(color)
      .fontWeight(FontWeight.Bold)
      .maxLines(isNavBar ? 1 : -1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .geometryTransition(
        (isNavBar || !this.vm.isSticky) ? TransitionMap.CollectionDetailPage : null,
        { follow: true }
      )
      .width(isNavBar ? "auto" : CommonConstant.FullPercent)
      .textAlign(TextAlign.Start)
      .transition(TransitionEffect.OPACITY.animation({ duration: CommonConstant.AnimationDurationNormal }))
  }

  @Builder
  tag(tagName: string) {
    Text(tagName)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding,
        top: CommonConstant.SmallContainerTBPadding,
        bottom: CommonConstant.SmallContainerTBPadding
      })
      .fontSize(CommonConstant.TextSizeSmall)
      .backgroundColor($r('app.color.start_window_background'))
      .borderRadius(CommonConstant.RadiusSmall)
      .fontColor($r('sys.color.font_secondary'))
  }

  @Builder
  description() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Text(this.vm.collection?.description ?? $r('app.string.CollectionContentPage_no_desc'))
        .fontSize(CommonConstant.TextSizeNormal)
        .width(CommonConstant.FullPercent)
        .textAlign(TextAlign.Start)

      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(`${ResUtil.getStringSync($r('app.string.CollectionContentPage_last_update'))}: ${this.vm.collection?.lastUpdate ??
          '--'}`)
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor($r('sys.color.font_tertiary'))

        Text("展开")
          .fontSize(CommonConstant.TextSizeTiny)
          .fontColor(CommonConstant.ThemeColor)
      }
      .width(CommonConstant.FullPercent)
      .justifyContent(FlexAlign.End)
    }
    .width(CommonConstant.FullPercent)
    .padding(CommonConstant.NormalContainerInnerPadding)
    .borderRadius(CommonConstant.RadiusNormal)
    .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })
    .backgroundColor($r('app.color.second_window_background'))
  }

  @Builder
  userSwiper() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Text($r('app.string.CollectionContentPage_recent_user'))
        .fontSize(CommonConstant.TextSizeNormal)
        .fontWeight(FontWeight.Medium)
        .width(CommonConstant.FullPercent)
        .textAlign(TextAlign.Start)

      List({ space: CommonConstant.NormalContainerInnerPadding }) {
        ForEach(this.vm.collectionDetail?.newSubsUser, (user: CollectionUser) => {
          ListItem() {
            Row({ space: CommonConstant.SmallContainerInnerPadding }) {
              Image(UserAvatarUtil.getAvatarUrl(user.uid))
                .width(CommonConstant.IconSizeSmall)
                .height(CommonConstant.IconSizeSmall)
                .borderRadius(CommonConstant.RadiusRound)

              Text(user.username)
                .fontSize(CommonConstant.TextSizeSmall)
                .fontColor($r('sys.color.font_secondary'))
            }
            .padding(CommonConstant.NormalContainerInnerPadding)
            .backgroundColor($r('app.color.second_window_background'))
            .borderRadius(CommonConstant.RadiusNormal)
          }
        }, (user: CollectionUser) => user.uid.toString())
      }
      .listDirection(Axis.Horizontal)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
      .width(CommonConstant.FullPercent)
      .scrollBar(BarState.Off)
    }
    .width(CommonConstant.FullPercent)
  }

  @Builder
  userOtherCollections() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Text(`${this.vm.collection?.creator.username} ${ResUtil.getStringSync($r('app.string.CollectionContentPage_more_collections'))}`)
        .fontSize(CommonConstant.TextSizeNormal)
        .fontWeight(FontWeight.Medium)
        .width(CommonConstant.FullPercent)
        .textAlign(TextAlign.Start)

      Swiper() {
        // 这里放更多淘专辑
      }
      .width(CommonConstant.FullPercent)
    }
    .width(CommonConstant.FullPercent)
  }

  @Builder
  CollectionDetailContent() {
    Column({ space: CommonConstant.LargeContainerInnerPadding }) {
      Column()
        .height(CommonConstant.TopBarHeight + this.vm.window.windowTopPadding)

      Row({ space: CommonConstant.LargeContainerInnerPadding }) {
        Column() {
          Text("淘专辑")
            .fontSize(CommonConstant.TextSizeUltraLarge)
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Bolder)
        }
        .width(this.decoCardSize)
        .height(this.decoCardSize)
        .borderRadius(CommonConstant.RadiusNormal)
        .backgroundColor(CommonConstant.ThemeColor)
        .border({ width: CommonConstant.BorderSizeLarge, color: $r('app.color.glass_border') })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)

        Column({ space: CommonConstant.NormalContainerInnerPadding }) {
          Text(this.vm.collection?.title)
            .fontSize(CommonConstant.TextSizeNormal)
            .fontWeight(FontWeight.Bold)

          Row({ space: CommonConstant.SmallContainerInnerPadding }) {
            Image(UserAvatarUtil.getAvatarUrl(this.vm.collection?.creator.uid || 0))
              .height(CommonConstant.IconSizeSmall)
              .width(CommonConstant.IconSizeSmall)
              .borderRadius(CommonConstant.RadiusRound)

            Text(this.vm.collection?.creator.username)
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_secondary'))
          }

          Row({ space: CommonConstant.SmallContainerInnerPadding }) {
            Text($r('app.string.CollectionContentPage_rate'))
              .fontSize(CommonConstant.TextSizeSmall)
              .fontColor($r('sys.color.font_tertiary'))

            if (this.vm.collectionDetail) {
              ForEach(Array.from({ length: 5 }), (_: number, index) => {
                SymbolGlyph(index < this.vm.collectionDetail?.rate! ? $r('sys.symbol.star_fill') :
                  $r('sys.symbol.star'))
                  .fontSize(CommonConstant.TextSizeSmall)
                  .fontColor([CommonConstant.ThemeColor])
              }, (_: number, index) => index.toString())
            } else {
              Text($r('app.string.CollectionContentPage_no_rate'))
                .fontSize(CommonConstant.TextSizeSmall)
                .fontColor($r('sys.color.font_tertiary'))
            }
          }

          Row({ space: CommonConstant.NormalContainerInnerPadding }) {
            Text(`${ResUtil.getStringSync($r('app.string.CollectionView_topic'))} ${this.vm.collection?.collection_nums}`)
              .fontSize(CommonConstant.TextSizeTiny)
              .fontColor($r('sys.color.font_tertiary'))

            Text(`${ResUtil.getStringSync($r('app.string.CollectionView_comment'))} ${this.vm.collection?.comment}`)
              .fontSize(CommonConstant.TextSizeTiny)
              .fontColor($r('sys.color.font_tertiary'))

            Text(`${ResUtil.getStringSync($r('app.string.CollectionView_subs'))} ${this.vm.collection?.subscribe}`)
              .fontSize(CommonConstant.TextSizeTiny)
              .fontColor($r('sys.color.font_tertiary'))
          }
        }
        .layoutWeight(1)
        .height(this.decoCardSize)
        .alignItems(HorizontalAlign.Start)
      }
      .width(CommonConstant.FullPercent)
      .justifyContent(FlexAlign.Start)

      if (this.vm.collection?.tags && this.vm.collection.tags.length > 0) {
        Flex({
          wrap: FlexWrap.Wrap,
          space: {
            main: LengthMetrics.vp(CommonConstant.SmallContainerInnerPadding),
            cross: LengthMetrics.vp(CommonConstant.SmallContainerInnerPadding)
          }
        }) {
          ForEach(this.vm.collection.tags, (tag: string) => {
            this.tag(tag)
          }, (tag: string, index: number) => `${tag}_${index}`)
        }
        .width(CommonConstant.FullPercent)
      }

      this.description()

      if (this.vm.collectionDetail?.newSubsUser) {
        this.userSwiper()
      }

      if (this.vm.collectionDetail?.userMoreCollections) {
        this.userOtherCollections()
      }
    }
    .padding({ left: CommonConstant.PageLRPadding, right: CommonConstant.PageLRPadding })
  }

  build() {
    Refresh({ refreshing: $$this.vm.isCollectionRefreshing }) {
      Stack({ alignContent: Alignment.Top }) {
        CustomFloatNavTitle({
          vm: this.vm,
          isFloating: !this.vm.isSticky,
          buttons: this.vm.titleButtons,
          content: () => {
            if (this.vm.isSticky) {
              this.CollectionTitle($r('sys.color.font_primary'), true)
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
                  this.CollectionDetailContent()
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
                  // this.vm.handleScroll(this.swiperHeight);
                }
              })
              .onScroll(() => {
                if (this.vm.isTabletView) {
                  this.vm.isReachEnd = this.vm.detailScroller.isAtEnd();
                }
              })
            }
            .height(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)

            if (this.vm.isTabletView) {
              Scroll(this.vm.tieScroller) {
                Column() {
                  // 占位
                  Column()
                    .width(CommonConstant.FullPercent)
                    .layoutWeight(1)
                }
                .width("auto")
                .justifyContent(FlexAlign.Start)
              }
              .height(CommonConstant.FullPercent)
              .layoutWeight(1)
              .align(Alignment.TopStart)
              .scrollBar(BarState.Off)
              .nestedScroll({
                scrollForward: NestedScrollMode.SELF_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST,
              })
              .onReachEnd(() => {
                // this.vm.loadMore();
              })
            } else {
              Column() {
                // 占位
                Column()
                  .width(CommonConstant.FullPercent)
                  .layoutWeight(1)
              }
              .width(CommonConstant.FullPercent)
            }
          }
          .height(this.vm.isTabletView ? CommonConstant.FullPercent : undefined)
        }
        .height(CommonConstant.FullPercent)
        .scrollable(this.vm.isTabletView ? ScrollDirection.None : ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .onDidScroll(() => {
          if (!this.vm.isTabletView) {
            // this.vm.handleScroll(this.swiperHeight);
          }
        })
        .onReachEnd(() => {
          if (!this.vm.isTabletView) {
            // this.vm.loadMore();
          }
        })
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.start_window_background'))
  }
}