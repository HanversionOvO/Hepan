import {
  BaseVM,
  Collection,
  CollectionApi,
  CollectionDetail,
  CommonConstant,
  RouterMap,
  RouterUtil
} from 'base_common';
import {
  LoneTakeAnimationsTransition,
  LongTakeAnimationProperties,
  LongTakeTransitionParam,
  NavTitleButtonModel
} from 'base_ui';
import { LongTakeTransitionOptions } from 'base_ui/src/main/ets/transitions/longtake/utils/Options';
import { curves } from '@kit.ArkUI';

const TAG = '[CollectionContentPageVM]: ';

@ObservedV2
export class CollectionContentPageVM extends BaseVM {
  @Trace isCollectionRefreshing: boolean = false;
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace collection: Collection | null = null;
  @Trace collectionDetail: CollectionDetail | null = null;
  @Trace isSticky: boolean = false;
  @Trace titleButtons: NavTitleButtonModel[] = [];
  @Trace outerPageScroller: Scroller = new Scroller();
  @Trace detailScroller: Scroller = new Scroller();
  @Trace tieScroller: Scroller = new Scroller();
  @Trace isReachEnd: boolean = false;
  @Trace pageScale: number = 1.0;

  async loadData() {
    if (this.collection) {
      this.collectionDetail = await CollectionApi.getCollectionDetail(this.collection.ctid);
    }
  }

  enterDetailPage(ctid: number, context: UIContext, collection: Collection) {
    let options: LongTakeTransitionOptions = {
      onEnterTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 0.8;
        })
      },
      onBackTransitionStart: () => {
        context.animateTo({ curve: curves.springMotion(0.35, 0.75) }, () => {
          this.pageScale = 1.0;
        })
      }
    };

    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(context,
        ctid.toString(), CommonConstant.RadiusLarge, options);

    const params: Record<string, Object> = {};

    if (longTakeTransitionParam) {
      let transitionParam: LongTakeTransitionParam = longTakeTransitionParam;
      params["transition"] = transitionParam;
    }

    params["collection"] = collection;

    RouterUtil.pushPathByName(RouterMap.COLLECTION_CONTENT_PAGE, params);
  }
}