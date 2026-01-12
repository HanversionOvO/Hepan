import { ApiClient, ApiResponse, LegacyResponse } from './ApiClient';
import { BaseResponse } from './models/UserModels';
import { http } from '@kit.NetworkKit';
import { LogUtil } from '@pura/harmony-utils';
import {
  AnPNotification,
  Chat,
  ChatSendContent,
  MessageListBody,
  MessageSummary,
  NotificationResponse,
  PmListBody,
  RecentMessage,
  SystemNotification,
  SystemNotificationBody
} from './models/MessageModels';
import { ToastUtil } from '../utils/ToastUtil';

const TAG = '[MessageApi]: ';

export class MessageApi {
  private static extractBaseData<T>(response: ApiResponse<BaseResponse<T>>, fallbackMessage: string): T {
    if (response.status === 200 && response.data.code === 0 &&
      response.data.data !== undefined && response.data.data !== null) {
      return response.data.data;
    }
    const errorMsg = response.data?.message || `${fallbackMessage}, status: ${response.status}`;
    LogUtil.warn(TAG, errorMsg);
    throw new Error(errorMsg);
  }

  private static ensureLegacySuccess<T>(response: ApiResponse<LegacyResponse<T>>, fallbackMessage: string): void {
    if (response.data && response.data.rs === 1) {
      return;
    }
    const errCode = response.data?.errcode || 'unknown';
    const errorMsg = `${fallbackMessage}, errcode: ${errCode}`;
    LogUtil.warn(TAG, errorMsg);
    throw new Error(errorMsg);
  }

  public static async getMessageSummary(): Promise<MessageSummary> {
    const path = `/_/messages/summary`;

    const response = await ApiClient.getInstance().request<BaseResponse<MessageSummary>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });

    return MessageApi.extractBaseData(response, 'Fetch message summary failed');
  }

  public static async getMessageList(page = 1, pagesize = 15): Promise<RecentMessage[]> {
    const json: Record<string, number> = {
      'page': page,
      'pagesize': pagesize
    };

    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse<MessageListBody>>('message', 'pmsessionlist', {
          'json': json
        });

    MessageApi.ensureLegacySuccess(result, 'Fetch message list failed');
    const list = result.data.body?.list;
    if (!list || !Array.isArray(list)) {
      return [];
    }
    return list;
  }

  public static async getNotificationList(type: 'at' | 'post', page = 1,
    pagesize = 15): Promise<AnPNotification[]> {
    const result =
      await ApiClient.getInstance()
        .requestLegacy<NotificationResponse>('message', 'notifylist', {
          'type': type,
          'page': page,
          'pagesize': pagesize
        });

    MessageApi.ensureLegacySuccess(result, 'Fetch notification list failed');
    return Array.isArray(result.data.list) ? result.data.list : [];
  }

  public static async getSystemNotification(page = 1, pagesize = 15): Promise<SystemNotification[]> {
    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse<SystemNotificationBody>>('message', 'notifylistex', {
          'type': 'system',
          'page': page,
          'pagesize': pagesize
        });

    MessageApi.ensureLegacySuccess(result, 'Fetch system notification failed');
    const data = result.data.body?.data;
    return Array.isArray(data) ? data : [];
  }

  public static async getChat(uid: number, start_time: number = 0, stop_time: number = 0,
    pageSize: number = 15, cacheCount?: number): Promise<Chat[]> {
    const actualCacheCount = cacheCount !== undefined ? cacheCount : pageSize;

    const pmlist: Record<string, Record<string, Array<Record<string, Object>>>> = {
      'body': {
        'pmInfos': [
          {
            'startTime': start_time,
            'stopTime': stop_time,
            'cacheCount': actualCacheCount,
            'fromUid': uid,
            'pmLimit': pageSize
          }
        ]
      }
    };

    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse<PmListBody>>('message', 'pmlist', {
          'pmlist': JSON.stringify(pmlist)
        });

    MessageApi.ensureLegacySuccess(result, 'Fetch chat messages failed');
    const pmList = result.data.body?.pmList;
    if (!pmList || !Array.isArray(pmList) || pmList.length === 0) {
      return [];
    }
    const msgList = pmList[0]?.msgList;
    return Array.isArray(msgList) ? msgList : [];
  }

  public static async queryOnline(uid: number): Promise<boolean> {
    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse<Record<string, Object>>>('user', 'userinfo', {
          'userId': uid
        });

    if (result.data.rs !== 1) {
      LogUtil.warn(TAG, `Query user online failed, errcode: ${result.data.errcode}`);
      return false;
    }
    return result.data.status === 2;
  }

  public static async sendMessage(uid: number, msg: ChatSendContent, plid: number, pmid: number): Promise<void> {
    const json: Record<string, Object> = {
      'action': 'send',
      'toUid': uid,
      'msg': msg,
      'plid': plid,
      'pmid': pmid
    };

    const result =
      await ApiClient.getInstance()
        .requestLegacy<LegacyResponse>('message', 'pmadmin', {
          'json': JSON.stringify(json)
        });

    if (result.data.rs === 1) {
      return;
    }
    const errorMsg = `Send message failed, errcode: ${result.data.errcode}`;
    LogUtil.warn(TAG, errorMsg);
    ToastUtil.showError(result.data.errcode);
    throw new Error(errorMsg);
  }
}
