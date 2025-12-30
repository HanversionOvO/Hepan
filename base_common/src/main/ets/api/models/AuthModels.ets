export interface AdoptLegacyAuthData {
  authorization: string;
  uid: number;
  user_settings_version: number;
  user_frontend_settings: Record<string, Object>;
}

export interface AdoptLegacyAuthUser {
  uid: number;
  username: string;
  new_pm_legacy: boolean;
  new_notification: number;
  new_pm: number;
  new_grouppm_legacy: boolean;
  settings_version: number;
}

export interface AdoptLegacyAuthSystem {
  settings_version: number;
  client_version: number;
}

export interface AdoptLegacyAuthResponse {
  code: number;
  message: string;
  data: AdoptLegacyAuthData;
  user: AdoptLegacyAuthUser;
  system: AdoptLegacyAuthSystem;
}

export interface LoginResult {
  authorization: string;
  cookie: string;
  uid: number;
  username: string;
}

export interface LegacyLoginData {
  token: string;
  secret: string;
  uid: number;
  userName: string;
}

export interface LegacyLoginResponse {
  token: string;
  secret: string;
  rs: number;
  errcode: string;
  body: LegacyLoginData
}