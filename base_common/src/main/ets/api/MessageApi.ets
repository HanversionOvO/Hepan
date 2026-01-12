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
  SystemNotificationData
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

  private static readonly systemKinds: string[] = [
    'friend',
    'space',
    'task',
    'report',
    'system',
    'admin',
    'app'
  ];

  private static formatHtmlMessage(html: string): string {
    if (!html) {
      return '';
    }
    const namedEntities: Record<string, string> = {
      'nbsp': ' ',
      'amp': '&',
      'lt': '<',
      'gt': '>',
      'quot': '"',
      'apos': '\'',
      '#39': '\'',
      'rsaquo': '\u203A',
      'lsaquo': '\u2039',
      'raquo': '\u00BB',
      'laquo': '\u00AB',
      'hellip': '\u2026',
      'ndash': '\u2013',
      'mdash': '\u2014',
      'ldquo': '\u201C',
      'rdquo': '\u201D',
      'lsquo': '\u2018',
      'rsquo': '\u2019'
    };
    let text = html;
    text = text.replace(/<br\s*\/?>/gi, '\n');
    text = text.replace(/<\/p>/gi, '\n');
    text = text.replace(/<[^>]+>/g, '');
    text = text.replace(/&#x([0-9a-fA-F]+);/g, (match: string, code: string): string => {
      const codePoint = parseInt(code, 16);
      return Number.isNaN(codePoint) ? '' : String.fromCodePoint(codePoint);
    });
    text = text.replace(/&#(\d+);/g, (match: string, code: string): string => {
      const codePoint = parseInt(code, 10);
      return Number.isNaN(codePoint) ? '' : String.fromCodePoint(codePoint);
    });
    text = text.replace(/&([a-zA-Z#0-9]+);/g, (match: string, name: string): string => {
      return namedEntities[name] ?? namedEntities[name.toLowerCase()] ?? match;
    });
    text = text.replace(/[ \t]+/g, ' ');
    text = text.replace(/\n\s+/g, '\n');
    return text.trim();
  }

  private static async getSystemNotificationByKind(kind: string, page: number): Promise<SystemNotification[]> {
    const path = `/_/messages/notifications?kind=${kind}&page=${page}`;
    const response = await ApiClient.getInstance().request<BaseResponse<SystemNotificationData>>({
      path: path,
      method: http.RequestMethod.GET,
      includeAuthorization: true,
      includeCookie: true
    });
    const data = MessageApi.extractBaseData(response, 'Fetch system notification failed');
    const rows = data.rows;
    if (!rows || !Array.isArray(rows) || rows.length === 0) {
      return [];
    }
    return rows.map((row) => {
      const item = new SystemNotification();
      item.id = row.id ?? 0;
      item.user_id = row.user_id ?? 0;
      item.type = row.type ?? '';
      item.unread = Boolean(row.unread);
      item.author_id = row.author_id ?? 0;
      item.author = row.author ?? '';
      item.html_message = row.html_message ?? '';
      item.message = MessageApi.formatHtmlMessage(item.html_message);
      item.dateline = row.dateline ?? 0;
      item.from_id = row.from_id ?? 0;
      item.from_id_type = row.from_id_type ?? '';
      item.from_num = row.from_num ?? 0;
      item.category = row.category ?? 0;
      item.friend_note = row.friend_note ?? '';
      return item;
    });
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

  public static async getSystemNotification(page = 1): Promise<SystemNotification[]> {
    const tasks = MessageApi.systemKinds.map((kind) => MessageApi.getSystemNotificationByKind(kind, page));
    const results = await Promise.allSettled(tasks);
    const merged: SystemNotification[] = [];
    let hasSuccess = false;
    results.forEach((result, index) => {
      if (result.status === 'fulfilled') {
        hasSuccess = true;
        merged.push(...result.value);
        return;
      }
      LogUtil.warn(TAG, `Fetch system notification failed for kind: ${MessageApi.systemKinds[index]}`);
    });
    if (!hasSuccess) {
      throw new Error('Fetch system notification failed');
    }
    if (merged.length === 0) {
      return [];
    }
    merged.sort((a, b) => b.dateline - a.dateline);
    return merged;
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
