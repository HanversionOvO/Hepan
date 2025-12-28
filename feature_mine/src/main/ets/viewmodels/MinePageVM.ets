import { BaseVM } from 'base_common';

@ObservedV2
export class MinePageVM extends BaseVM {
  @Trace outerScrollScroller: Scroller = new Scroller();
  @Trace isSticky: boolean = false;

  startMine() {
  }
}