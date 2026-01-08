import { LogUtil } from '@pura/harmony-utils';
import { ApiClient } from './ApiClient';

const TAG = '[CollectionApi]: ';

export class CollectionApi {
  public static async getCollections(): Promise<void> {
    const response = await ApiClient.getInstance().requestLegacy<Record<string, Object>>('forum', 'postlist');

    if (response.status === 200) {

    } else {
      const errorMsg = `Publish thread failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}