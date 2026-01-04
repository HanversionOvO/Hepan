import { BaseVM } from 'base_common';
import { preferences } from '@kit.ArkData';
import { AppUtil, LogUtil } from '@pura/harmony-utils';

const TAG = 'DraftVM';
const PREF_NAME = 'hepan_drafts_store';
const KEY_DRAFTS = 'draft_list';

export interface DraftData {
  title: string;
  content: string;
  timeStr: string;
  timestamp: number;
}

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
    const date = new Date(this.timestamp);
    this.timeStr = `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()} ${date.getHours()
      .toString()
      .padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  static fromData(data: DraftData): DraftModel {
    const model = new DraftModel(data.title, data.content);
    model.timeStr = data.timeStr;
    model.timestamp = data.timestamp;
    return model;
  }
}

@ObservedV2
export class DraftVM extends BaseVM {
  @Trace draftList: DraftModel[] = [];

  constructor() {
    super();
    this.loadDrafts();
  }

  async loadDrafts() {
    try {
      const context = AppUtil.getContext();
      const pref = await preferences.getPreferences(context, PREF_NAME);
      const jsonStr = await pref.get(KEY_DRAFTS, '[]');

      const rawList = JSON.parse(jsonStr as string) as DraftData[];

      if (Array.isArray(rawList)) {
        this.draftList = rawList.map(item => DraftModel.fromData(item));

        this.draftList.sort((a, b) => b.timestamp - a.timestamp);
      }
    } catch (e) {
      LogUtil.error(TAG, 'Load drafts failed:', e);
    }
  }

  // 保存草稿
  async saveDraft(title: string, content: string): Promise<boolean> {
    try {
      const newDraft = new DraftModel(title, content);
      this.draftList.unshift(newDraft);
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

  private async persist() {
    try {
      const context = AppUtil.getContext();
      const pref = await preferences.getPreferences(context, PREF_NAME);

      const dataToSave: DraftData[] = this.draftList.map(item => ({
        title: item.title,
        content: item.content,
        timeStr: item.timeStr,
        timestamp: item.timestamp
      } as DraftData));

      await pref.put(KEY_DRAFTS, JSON.stringify(dataToSave));
      await pref.flush();
    } catch (e) {
      LogUtil.error(TAG, 'Persist drafts failed:', e);
    }
  }
}