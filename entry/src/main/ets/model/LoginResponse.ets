/**
 * 用户信息类型
 */
export interface UserInfo {
  id?: number;
  username?: string;
  nickname?: string;
  avatar?: string;
}

/**
 * 登录响应类型
 */
export interface LoginResponse {
  message: string;
  userId: number;
  username: string;
  role: string;
  token: string;
  user?: UserInfo;
}