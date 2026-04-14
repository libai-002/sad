



/**
 * 用户信息类型
 */
export interface UserInfo {
  id?: number;
  username?: string;
  nickname?: string;
  avatar?: string;
  // 移除索引签名，使用具体的属性定义
}

/**
 * 认证服务
 * 处理用户认证、令牌管理等功能
 */
export class AuthService {
  /**
   * 存储用户令牌
   * @param token string 认证令牌
   */
  static saveToken(token: string): void {
    AppStorage.setOrCreate('userToken', token);
  }

  /**
   * 存储用户信息
   * @param user UserInfo 用户信息
   */
  static saveUserInfo(user: UserInfo): void {
    AppStorage.setOrCreate('userInfo', user);
  }

  /**
   * 获取用户令牌
   * @returns string | undefined 认证令牌
   */
  static getToken(): string | undefined {
    return AppStorage.get('userToken') as string;
  }

  /**
   * 获取用户信息
   * @returns UserInfo | undefined 用户信息
   */
  static getUserInfo(): UserInfo | undefined {
    return AppStorage.get('userInfo') as UserInfo;
  }

  /**
   * 检查用户是否已登录
   * @returns boolean 是否已登录
   */
  static isLoggedIn(): boolean {
    return !!AppStorage.get('userToken');
  }

  /**
   * 清除用户认证信息
   */
  static clearAuthInfo(): void {
    AppStorage.delete('userToken');
    AppStorage.delete('userInfo');
  }
}