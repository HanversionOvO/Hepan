import { ApiClient } from './ApiClient';
import { BaseResponse } from './models/UserModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';
import { AnPNotification, MessageSummary, RecentMessage, SystemNotification } from './models/MessageModels';
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

  public static async getMessageList(page = 1, pagesize = 15): Promise<RecentMessage[]> {
    const json: Record<string, number> = {
      'page': page,
      'pagesize': pagesize
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

  public static async getNotificationList(type: 'at' | 'post', page = 1,
    pagesize = 15): Promise<AnPNotification[]> {
    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse>('message', 'notifylist', {
          'type': type,
          'page': page,
          'pagesize': pagesize
        });

    if (result.data.rs === 1 && result.data.list) {
      return result.data.list;
    } else {
      const errorMsg = `Fetch full profile failed, status: ${result.data.errcode}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getSystemNotification(page = 1, pagesize = 15): Promise<SystemNotification[]> {
    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse<Record<string, Object>>>('message', 'notifylistex', {
          'type': 'system',
          'page': page,
          'pagesize': pagesize
        });

    if (result.data.rs === 1 && result.data.body) {
      return result.data.body['data'] as SystemNotification[];
    } else {
      const errorMsg = `Fetch full profile failed, status: ${result.data.errcode}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public static async getChat(uid: number, start_time: number = 0, stop_time: number = 0): Promise<void> {
    const pmlist: Record<string, Record<string, Record<string, Object>>> = {
      'body': {
        "externInfo": { "onlyFromUid": 0 },
        'pmInfos': {
          'startTime': start_time,
          'stopTime': stop_time,
          'cacheCount': 1,
          'fromUid': uid.toString(),
          'pmLimit': 10
        }
      }
    }

    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse>('message', 'pmlist', {
          'pmlist': pmlist
        });

    LogUtil.debug(TAG, JSON.stringify(result.data));

    if (result.data.rs === 1 && result.data.body) {

    } else {
      const errorMsg = `Fetch full profile failed, status: ${result.data.errcode}`;
      LogUtil.warn(TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }
}