import { NetworkService } from './NetworkService';
import { UserInfo, AuthService } from './AuthService';

/**
 * 用户个人资料类型
 */
export interface UserProfile extends UserInfo {
  bio?: string;
  gender?: string;
  birthday?: string;
  location?: string;
}

/**
 * 好友信息类型
 */
export interface FriendInfo extends UserInfo {
  status?: string;
  addedAt?: string;
}

/**
 * 登录历史记录类型
 */
export interface LoginHistoryItem {
  time: string;
  ip: string;
  device: string;
}

/**
 * 操作结果类型
 */
export interface OperationResult {
  success: boolean;
  message: string;
}

/**
 * 账号安全信息类型
 */
export interface AccountSecurity {
  twoFactorEnabled?: boolean;
  lastLogin?: string;
  loginHistory?: Array<LoginHistoryItem>;
}

/**
 * 密码修改请求类型
 */
export interface ChangePasswordRequest {
  oldPassword: string;
  newPassword: string;
  confirmPassword: string;
}

/**
 * 好友请求类型
 */
export interface AddFriendRequest {
  username: string | number;
}

/**
 * 用户服务
 * 处理用户相关的后端接口调用
 */
export class UserService {
  /**
   * 获取当前用户信息
   * @returns UserInfo 当前用户信息
   * @throws Error 如果用户未登录或用户信息不完整
   */
  private static getCurrentUserInfo(): UserInfo {
    console.log('开始获取当前用户信息');
    const userInfo = AuthService.getUserInfo();
    console.log('获取到的用户信息:', JSON.stringify(userInfo));
    if (!userInfo || !userInfo.id) {
      console.error('用户未登录或用户信息不完整');
      throw new Error('用户未登录或用户信息不完整');
    }
    console.log('获取当前用户信息成功，用户ID:', userInfo.id, '用户名:', userInfo.username);
    return userInfo;
  }

  /**
   * 获取用户个人资料
   * @returns Promise<UserProfile> 用户个人资料
   */
  static async getUserProfile(): Promise<UserProfile> {
    const userInfo = UserService.getCurrentUserInfo();
    return await NetworkService.get<UserProfile>(`/api/users/${userInfo.id}`);
  }

  /**
   * 更新用户个人资料
   * @param data Partial<UserProfile> 更新数据
   * @returns Promise<OperationResult> 更新结果
   */
  static async updateUserProfile(data: Partial<UserProfile>): Promise<OperationResult> {
    const userInfo = UserService.getCurrentUserInfo();
    return await NetworkService.post<OperationResult>(`/api/users/${userInfo.id}`, data);
  }

  /**
   * 获取用户好友列表
   * @returns Promise<Array<FriendInfo>> 好友列表
   */
  static async getFriends(): Promise<Array<FriendInfo>> {
    const userInfo = UserService.getCurrentUserInfo();
    return await NetworkService.get<Array<FriendInfo>>(`/api/users/${userInfo.id}/friends`);
  }

  /**
   * 发送好友请求
   * @param userId number 好友用户ID
   * @returns Promise<OperationResult> 请求结果
   */
  static async sendFriendRequest(userId: number): Promise<OperationResult> {
    const userInfo = UserService.getCurrentUserInfo();
    const friendRequest: AddFriendRequest = { username: userId };
    return await NetworkService.post<OperationResult>(`/api/users/${userInfo.id}/friends`, friendRequest);
  }

  /**
   * 添加好友
   * @param username string 好友用户名
   * @returns Promise<OperationResult> 添加结果
   */
  static async addFriend(username: string): Promise<OperationResult> {
    console.log('开始执行addFriend方法，好友用户名:', username);
    try {
      const userInfo = UserService.getCurrentUserInfo();
      console.log('准备发送添加好友请求，用户ID:', userInfo.id, '好友用户名:', username);
      
      const friendRequest: AddFriendRequest = { username: username };
      console.log('构建的好友请求对象:', JSON.stringify(friendRequest));
      
      const apiUrl = `/api/users/${userInfo.id}/friends`;
      console.log('发送请求到API端点:', apiUrl);
      
      const result = await NetworkService.post<OperationResult>(`/api/users/${userInfo.id}/friends`, friendRequest);
      console.log('API返回结果:', JSON.stringify(result));
      
      console.log('addFriend方法执行成功');
      return result;
    } catch (error) {
      console.error('addFriend方法执行失败:', error instanceof Error ? error.message : JSON.stringify(error));
      // 在ArkTS中，throw语句只能抛出Error类型的对象
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(error instanceof String ? error as string : JSON.stringify(error));
      }
    }
  }

  /**
   * 获取账号安全信息
   * @returns Promise<AccountSecurity> 账号安全信息
   */
  static async getAccountSecurity(): Promise<AccountSecurity> {
    // 由于后端没有提供安全信息接口，返回默认空对象
    return {} as AccountSecurity;
  }

  /**
   * 修改密码
   * @param data ChangePasswordRequest 密码修改数据
   * @returns Promise<OperationResult> 修改结果
   */
  static async changePassword(data: ChangePasswordRequest): Promise<OperationResult> {
    const userInfo = UserService.getCurrentUserInfo();
    return await NetworkService.post<OperationResult>(`/api/users/${userInfo.id}/password`, data);
  }
}