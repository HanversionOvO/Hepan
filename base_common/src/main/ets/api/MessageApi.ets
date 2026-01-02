import { ApiClient } from './ApiClient';
import { BaseResponse } from './models/UserModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';
import { MessageSummary, RecentMessage } from './models/MessageModels';
import { LegacyResponse } from './models/ApiModels';

const TAG = '[MessageApi]: ';

export class MessageApi {
  public static async getMessageSummary(): Promise<MessageSummary> {
    const path = `/_/messages/summary`;

    const response = await ApiClient.getInstance().request<BaseResponse<MessageSummary>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data;
    } else {
      // 抛出具体错误供 VM 处理
      const errorMsg = response.data?.message || `Fetch profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getMessageList(): Promise<RecentMessage[]> {
    const json: Record<string, number> = {
      'page': 1,
      'pagesize': 20
    }

    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse<Record<string, RecentMessage[]>>>('message', 'pmsessionlist', {
          "json": json
        });

    if (result.data.rs === 1 && result.data.body) {
      return result.data.body["list"];
    } else {
      const errorMsg = `Fetch full profile failed, status: ${result.data.errcode}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}