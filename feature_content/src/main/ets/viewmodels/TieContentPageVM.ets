import { BaseVM, ForumTieSummary } from 'base_common';
import { LongTakeAnimationProperties } from 'base_ui';

const TAG = '[TieContentPageVM]: ';

@ObservedV2
export class TieContentPageVM extends BaseVM {
  @Trace longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Trace tieSummary: ForumTieSummary | null = null;

  async loadData() {

  }
}