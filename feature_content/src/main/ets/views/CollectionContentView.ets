import {
  Collection,
  CollectionUser,
  CommonConstant,
  ForumTieSummary,
  TransitionMap,
  UserAvatarUtil
} from 'base_common';
import { CustomFloatNavTitle, StateLayout } from 'base_ui';
import { CollectionContentPageVM } from '../viewmodels/CollectionContentPageVM';
import { LengthMetrics } from '@kit.ArkUI';
import { ResUtil } from '@pura/harmony-utils';
import { CollectionCard } from '../components/CollectionCard';
import { TieCard } from '../components/TieCard';

@ComponentV2
export struct CollectionContentView {
  @Param @Require vm: CollectionContentPageVM;
  @Local sideNavWidth: number = 380;
  @Local decoCardSize: number = 108;

  @Computed
  get spacerArray(): number[] {
    return new Array(this.vm.columns).fill(0);
  }

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
      .backgroundColor($r('app.color.second_window_background'))
      .borderRadius(CommonConstant.RadiusSmall)
      .fontColor($r('sys.color.font_secondary'))
  }

  @Builder
  description() {
    Column({ space: CommonConstant.NormalContainerInnerPadding }) {
      Text(this.vm.collection?.description && this.vm.collection.description !== "" ? this.vm.collection.description :
        $r('app.string.CollectionContentPage_no_desc'))
        .fontSize(CommonConstant.TextSizeNormal)
        .width(CommonConstant.FullPercent)
        .textAlign(TextAlign.Start)

      Text(`${ResUtil.getStringSync($r('app.string.CollectionContentPage_last_update'))}: ${this.vm.collection?.lastUpdate ??
        '--'}`)
        .fontSize(CommonConstant.TextSizeTiny)
        .fontColor($r('sys.color.font_tertiary'))
        .width(CommonConstant.FullPercent)
        .textAlign(TextAlign.End)
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
        ForEach(this.vm.collectionDetail?.userMoreCollections, (collection: Collection) => {
          Column() {
            CollectionCard({ collection: collection })
              .id(this.vm.collection?.ctid.toString() + "_" + collection.ctid.toString())
          }
          .width(CommonConstant.FullPercent)
          .onClick(() => {
            this.vm.enterDetailPage(this.vm.collection?.ctid.toString() + "_" + collection.ctid.toString(),
              this.getUIContext(), collection)
          })
        }, (item: Collection) => item.ctid.toString())
      }
      .width(CommonConstant.FullPercent)
      .autoPlay(true)
      .loop(true)
      .itemSpace(CommonConstant.NormalContainerInnerPadding)
      .indicator(false)
      .effectMode(EdgeEffect.Spring)
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

  @Builder
  TieList() {
    StateLayout({
      uiState: this.vm.tieLoadingState,
      onRetry: () => {
        this.vm.loadTies(true);
      }
    }) {
      WaterFlow() {
        if (this.vm.isTabletView) {
          ForEach(this.spacerArray, (_: number, i: number) => {
            FlowItem() {
              Column().height(this.vm.window.windowTopPadding)
            }
            .width(CommonConstant.FullPercent)
          }, (_: number, i: number) => `top_spacer_${this.vm.columns}_${i}`)
        }

        ForEach(this.vm.ties, (tie: ForumTieSummary) => {
          FlowItem() {
            TieCard({
              tie: tie,
              forumName: tie.forum_name
            })
              .id(this.vm.collection?.ctid.toString() + "_" + tie.thread_id.toString())
              .onClick(() => {
                this.vm.enterTieDetailPage(this.vm.collection?.ctid.toString() + "_" + tie.thread_id.toString(),
                  this.getUIContext(), tie);
              })
          }
          .width(CommonConstant.FullPercent)
        }, (item: ForumTieSummary) => item.thread_id.toString())
      }
      .columnsTemplate('1fr '.repeat(this.vm.columns).trim())
      .padding({
        left: CommonConstant.PageLRPadding,
        right: CommonConstant.PageLRPadding
      })
      .columnsGap(CommonConstant.NormalContainerInnerPadding)
      .rowsGap(CommonConstant.NormalContainerInnerPadding)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .onReachEnd(() => {
        this.vm.loadTies(false);
      })
      .priorityGesture(
        PinchGesture()
          .onActionUpdate((event: GestureEvent) => {
            if (this.vm.isScaling) {
              return;
            }
            if (event.scale < 0.75 && this.vm.columns < this.vm.maxColumns) {
              animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.columns += 1;
              });
              this.vm.isScaling = true;
            }

            if (event.scale > 1.25 && this.vm.columns > this.vm.minColumns) {
              animateTo({
                duration: CommonConstant.AnimationDurationNormal,
                curve: CommonConstant.AnimationCurveSpring
              }, () => {
                this.vm.columns -= 1;
              });
              this.vm.isScaling = true;
            }
          })
          .onActionEnd(() => {
            this.vm.isScaling = false;
          })
      )
      .width(CommonConstant.FullPercent)
      .layoutWeight(1)
    }
  }

  @Builder
  followCard() {
    Row() {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        Image(UserAvatarUtil.getAvatarUrl(this.vm.collection?.creator.uid || 0))
          .width(CommonConstant.IconSizeNormal)
          .height(CommonConstant.IconSizeNormal)
          .borderRadius(CommonConstant.RadiusRound)

        Text(`${this.vm.collection?.creator.username} ${ResUtil.getStringSync($r('app.string.CollectionContentPage_created'))}`)
          .fontSize(CommonConstant.TextSizeSmall)
      }

      Button() {
        Row({ space: CommonConstant.SmallContainerInnerPadding }) {
          SymbolGlyph(this.vm.collectionDetail?.isFollow ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'))
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor(this.vm.collectionDetail?.isFollow ? [$r('sys.color.font_secondary')] :
              [$r('sys.color.font_on_primary')])

          Text(this.vm.collectionDetail?.isFollow ? $r('app.string.CollectionContentPage_has_collect') :
            $r('app.string.CollectionContentPage_collect'))
            .fontSize(CommonConstant.TextSizeTiny)
            .fontColor(this.vm.collectionDetail?.isFollow ? $r('sys.color.font_secondary') :
              $r('sys.color.font_on_primary'))
        }
      }
      .height(CommonConstant.IconSizeNormal)
      .padding({
        left: CommonConstant.SmallContainerLRPadding,
        right: CommonConstant.SmallContainerLRPadding
      })
      .backgroundColor(this.vm.collectionDetail?.isFollow ? $r('sys.color.font_tertiary') : CommonConstant.ThemeColor)
      .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring })
      .onClick(async () => {
        await this.vm.toggleSubs()
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(this.vm.isTabletView ? this.sideNavWidth - CommonConstant.PageLRPadding * 2 : "92%")
    .borderRadius(CommonConstant.RadiusRound)
    .backgroundColor($r('app.color.glass_background'))
    .border({ width: CommonConstant.BorderSizeNormal, color: $r('app.color.glass_border') })
    .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
    .padding({
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding,
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
    })
    .position({
      left: this.vm.isTabletView ? CommonConstant.PageLRPadding : "4%",
      bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerInnerPadding
    })
    .transition(TransitionEffect.move(TransitionEdge.BOTTOM)
      .animation({ duration: CommonConstant.AnimationDurationNormal, curve: CommonConstant.AnimationCurveSpring }))
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
                  this.vm.handleScroll();
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
                  this.TieList()
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
                this.vm.loadTies(false);
              })
            } else {
              Column() {
                this.TieList()
              }
              .width(CommonConstant.FullPercent)
            }
          }
        }
        .height(CommonConstant.FullPercent)
        .scrollable(this.vm.isTabletView ? ScrollDirection.None : ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .onDidScroll(() => {
          if (!this.vm.isTabletView) {
            this.vm.handleScroll();
          }
        })
        .onReachEnd(() => {
          if (!this.vm.isTabletView) {
            this.vm.loadTies(false);
          }
        })

        if (this.vm.collectionDetail) {
          this.followCard()
        }
      }
    }
    .width(CommonConstant.FullPercent)
    .height(CommonConstant.FullPercent)
    .backgroundColor($r('app.color.start_window_background'))
    .onRefreshing(() => {
      this.vm.loadTies(true);
    })
  }
}