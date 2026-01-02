import { ApiClient } from './ApiClient';
import { BaseResponse } from './models/UserModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';
import { MessageSummary, NewMessagesSummary } from './models/MessageModels';

const TAG = '[MessageApi]: ';

export class MessageApi {
  public static async getMessageSummary(): Promise<NewMessagesSummary> {
    const path = `/_/messages/summary`;

    const response = await ApiClient.getInstance().request<BaseResponse<MessageSummary>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    if (response.status === 200 && response.data.code === 0) {
      return response.data.data.new_messages;
    } else {
      // 抛出具体错误供 VM 处理
      const errorMsg = response.data?.message || `Fetch profile failed, status: ${response.status}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}