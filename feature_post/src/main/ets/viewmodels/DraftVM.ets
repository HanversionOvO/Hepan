import { AppUtil, LogUtil } from '@pura/harmony-utils';
import { BaseVM } from 'base_common';
import { preferences } from '@kit.ArkData';

const TAG = 'DraftVM';
const PREF_NAME = 'hepan_drafts_store';
const KEY_DRAFTS = 'draft_list';

@ObservedV2
export class DraftModel {
  @Trace title: string = '';
  @Trace content: string = '';
  @Trace timeStr: string = '';
  timestamp: number = 0;

  constructor(title: string, content: string) {
    this.title = title;
    this.content = content;
    this.timestamp = new Date().getTime();
    // 简单的日期格式化
    const date = new Date(this.timestamp);
    this.timeStr = `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()} ${date.getHours()
      .toString()
      .padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
}

@ObservedV2
export class DraftVM extends BaseVM {
  @Trace draftList: DraftModel[] = [];

  constructor() {
    super();
    this.loadDrafts();
  }

  // 加载草稿
  async loadDrafts() {
    try {
      const context = AppUtil.getContext();
      const pref = await preferences.getPreferences(context, PREF_NAME);
      const jsonStr = await pref.get(KEY_DRAFTS, '[]');
      const rawList = JSON.parse(jsonStr as string) as DraftModel[];

      // 转换为 Observed 对象
      this.draftList = rawList.map(item => {
        const model = new DraftModel(item.title, item.content);
        model.timeStr = item.timeStr;
        model.timestamp = item.timestamp;
        return model;
      });
      // 按时间倒序
      this.draftList.sort((a, b) => b.timestamp - a.timestamp);
    } catch (e) {
      LogUtil.error(TAG, 'Load drafts failed:', e);
    }
  }

  // 保存草稿
  async saveDraft(title: string, content: string): Promise<boolean> {
    try {
      const newDraft = new DraftModel(title, content);
      this.draftList.unshift(newDraft); // 添加到头部
      await this.persist();
      return true;
    } catch (e) {
      LogUtil.error(TAG, 'Save draft failed:', e);
      return false;
    }
  }

  // 删除草稿
  async deleteDraft(index: number) {
    if (index >= 0 && index < this.draftList.length) {
      this.draftList.splice(index, 1);
      await this.persist();
    }
  }

  // 持久化到 Preferences
  private async persist() {
    const context = AppUtil.getContext();
    const pref = await preferences.getPreferences(context, PREF_NAME);
    await pref.put(KEY_DRAFTS, JSON.stringify(this.draftList));
    await pref.flush();
  }
}