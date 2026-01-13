import { CommonConstant, ForumApi, TieFavoriteStatus, TiePublicFavorite } from 'base_common';
import { TieContentPageVM } from '../viewmodels/TieContentPageVM';

@Builder
export function tieCollectSheet(vm: TieContentPageVM) {
  TieCollectSheet({ vm: vm })
}

@ComponentV2
struct TieCollectSheet {
  @Param @Require vm: TieContentPageVM;
  @Local collectionItems: TieCollectItem[] = [];
  @Local isUpdating: boolean = false;

  async aboutToAppear() {
    const threadId = this.vm.tieThread.thread_id || this.vm.tieSummary.thread_id;
    await this.refreshStatus(threadId);
  }

  private async refreshStatus(threadId: number): Promise<void> {
    if (!threadId) {
      return;
    }
    try {
      const status = await ForumApi.getTieFavoriteStatus(threadId);
      this.collectionItems = this.buildItems(status);
    } catch {
      this.collectionItems = this.buildItems();
    }
  }

  private async toggleFavorite(item: TieCollectItem): Promise<void> {
    if (this.isUpdating) {
      return;
    }
    const threadId = this.vm.tieThread.thread_id || this.vm.tieSummary.thread_id;
    if (!threadId) {
      return;
    }

    this.isUpdating = true;
    try {
      if (item.isPersonal) {
        if (item.isFavorite) {
          await ForumApi.removePersonalFavorite(threadId);
        } else {
          await ForumApi.addPersonalFavorite(threadId);
        }
      } else if (item.collectionId > 0) {
        if (item.isFavorite) {
          await ForumApi.removeCollectionFavorite(threadId, item.collectionId);
        } else {
          await ForumApi.addCollectionFavorite(threadId, item.collectionId);
        }
      }
      await this.refreshStatus(threadId);
    } finally {
      this.isUpdating = false;
    }
  }

  private buildItems(status?: TieFavoriteStatus): TieCollectItem[] {
    const items: TieCollectItem[] = [];
    const personalFavorite = status?.is_personal_favorite === true;
    items.push(new TieCollectItem({
      isPersonal: true,
      isFavorite: personalFavorite
    }));

    const publicFavorites: TiePublicFavorite[] = status?.public_favorites || [];
    publicFavorites.forEach((favorite) => {
      items.push(new TieCollectItem({
        isPersonal: false,
        isFavorite: favorite.is_favorite === true,
        collectionId: favorite.collection_id,
        name: favorite.name || '',
        description: favorite.description || ''
      }));
    });
    return items;
  }

  @Builder
  CollectionItem(item: TieCollectItem) {
    Row() {
      Row({ space: CommonConstant.NormalContainerInnerPadding }) {
        SymbolGlyph(item.isPersonal ? $r('sys.symbol.person') : $r('sys.symbol.bookshelf'))
          .fontColor([CommonConstant.ThemeColor])
          .fontSize(CommonConstant.IconSizeNormal)
          .padding(CommonConstant.NormalContainerInnerPadding)
          .borderRadius(CommonConstant.RadiusNormal)
          .border({
            width: CommonConstant.BorderSizeLarge,
            color: $r('sys.color.font_tertiary'),
            style: BorderStyle.Dashed
          })

        Text(item.isPersonal ? $r('app.string.TieContentPage_personal_collection') : item.name)
          .fontSize(CommonConstant.TextSizeNormal)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .width(0)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .constraintSize({ minWidth: 0 })

      Row({ space: CommonConstant.SmallContainerInnerPadding }) {
        Text(item.isFavorite ? $r('app.string.TieContentPage_remove_collection') :
          $r('app.string.TieContentPage_add_collection'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        SymbolGlyph(item.isFavorite ? $r('sys.symbol.minus') : $r('sys.symbol.plus'))
          .fontSize(CommonConstant.TextSizeSmall)
          .fontColor([$r('sys.color.font_secondary')])
          .fontWeight(FontWeight.Bold)
      }
    }
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      top: CommonConstant.NormalContainerTBPadding,
      bottom: CommonConstant.NormalContainerTBPadding
    })
    .width(CommonConstant.FullPercent)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.toggleFavorite(item);
    })
  }

  build() {
    Column() {
      Column() {
        ForEach(this.collectionItems, (item: TieCollectItem) => {
          this.CollectionItem(item);
        }, (item: TieCollectItem) => {
          return item.isPersonal ? 'personal_favorite' : `public_${item.collectionId}_${item.isFavorite}`;
        })
      }
      .width(CommonConstant.FullPercent)
      .borderRadius(CommonConstant.RadiusNormal)
      .backgroundColor($r('app.color.start_window_background'))
    }
    .width(CommonConstant.FullPercent)
    .padding({
      left: CommonConstant.NormalContainerLRPadding,
      right: CommonConstant.NormalContainerLRPadding,
      bottom: this.vm.window.windowBottomPadding + CommonConstant.NormalContainerTBPadding
    })
  }
}

interface TieCollectItemOptions {
  isPersonal: boolean;
  isFavorite: boolean;
  collectionId?: number;
  name?: string;
  description?: string;
}

@ObservedV2
class TieCollectItem {
  @Trace isPersonal: boolean = false;
  @Trace isFavorite: boolean = false;
  @Trace collectionId: number = 0;
  @Trace name: string = '';
  @Trace description: string = '';

  constructor(options?: TieCollectItemOptions) {
    if (options) {
      this.isPersonal = options.isPersonal ?? this.isPersonal;
      this.isFavorite = options.isFavorite ?? this.isFavorite;
      this.collectionId = options.collectionId ?? this.collectionId;
      this.name = options.name ?? this.name;
      this.description = options.description ?? this.description;
    }
  }
}
