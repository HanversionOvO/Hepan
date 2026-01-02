import { AnPNotification } from './MessageModels';

export interface LegacyResponse<T = Object> {
  rs: number; // 成功标记: 1 为成功, 0 为失败
  errcode: string; // 错误码
  head?: LegacyHead; // 响应头信息
  body?: T; // 响应体
  pois?: Record<string, string>[];
  list?: AnPNotification[];
  status?: number;
}

export interface LegacyHead {
  errInfo?: string; // 错误描述信息
  version?: string;
}