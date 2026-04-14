import { NetworkService } from './NetworkService';
import { AuthService } from './AuthService';
import { AppStore01, SquadResponse, OperationResult, LeaveSquadRequest, JoinRequest } from './AppStore01';

/**
 * 搜索参数类型
 */
type ParamsObject = Record<string, string | number | boolean | null | undefined>;

/**
 * 小队服务
 * 处理小队相关的后端接口调用
 */
export class SquadService {
  /**
   * 获取用户已加入的小队列表
   * @returns Promise<Array<SquadResponse>> 小队列表
   */
  static async getJoinedSquads(): Promise<Array<SquadResponse>> {
    const userInfo = AuthService.getUserInfo();
    if (!userInfo || !userInfo.id) {
      throw new Error('用户未登录或用户信息不完整');
    }
    return await NetworkService.get<Array<SquadResponse>>(`/api/squads/joined/${userInfo.id}`);
  }

  /**
   * 获取小队详情
   * @param squadId number 小队ID
   * @returns Promise<SquadResponse> 小队详情
   */
  static async getSquadById(squadId: number): Promise<SquadResponse> {
    return await NetworkService.get<SquadResponse>(`/api/squads/by-id/${squadId}`);
  }

  /**
   * 退出小队
   * @param squadId number 小队ID
   * @returns Promise<OperationResult> 退出结果
   */
  static async leaveSquad(squadId: number): Promise<OperationResult> {
    const userInfo = AuthService.getUserInfo();
    if (!userInfo || !userInfo.id) {
      throw new Error('用户未登录或用户信息不完整');
    }
    const requestBody: LeaveSquadRequest = {
      userId: userInfo.id,
      squadId: squadId
    };
    return await NetworkService.post<OperationResult>('/api/squads/leave/by-id', requestBody);
  }

  /**
   * 获取小队成员ID列表
   * @param squadId number 小队ID
   * @returns Promise<Array<number>> 成员ID列表
   */
  static async getSquadMemberIds(squadId: number): Promise<Array<number>> {
    const squad = await SquadService.getSquadById(squadId);
    return squad.memberIds || [];
  }

  /**
   * 获取小队名称
   * @param squadId number 小队ID
   * @returns Promise<string> 小队名称
   */
  static async getSquadName(squadId: number): Promise<string> {
    const squad = await SquadService.getSquadById(squadId);
    return squad.name || '';
  }

  /**
   * 获取随机不重复的小队列表（使用简化版本，不包含邀请码）
   * @param limit number 小队数量限制（默认4个）
   * @returns Promise<Array<SquadResponse>> 小队列表，未登录时返回空数组
   */
  static async getRandomUniqueSquads(limit: number = 4): Promise<Array<SquadResponse>> {
    try {
      // 获取用户信息
      const userInfo = AuthService.getUserInfo();
      
      // 检查用户是否已登录
      if (!userInfo || !userInfo.id) {
        console.error('用户未登录，无法获取随机小队');
        return [];
      }
      
      // 调用后端接口获取随机不重复的小队（使用简化版本，不包含邀请码）
      const newSquads = await NetworkService.get<Array<SquadResponse>>(`/api/squads/random-unique/lite?userId=${userInfo.id}&limit=${limit}`);
      
      // 将新获取的小队数据存储到AppStore01中
      AppStore01.addSquads(newSquads);
      
      // 返回AppStore01中的所有小队数据
      return AppStore01.getSquads();
    } catch (error) {
      console.error('获取随机小队失败:', error);
      // 即使出错，也返回AppStore01中已有的数据
      return AppStore01.getSquads();
    }
  }

  /**
   * 加入小队
   * @param identifier string 加入标识符（小队ID或邀请码）
   * @returns Promise<SquadResponse> 加入的小队信息
   */
  static async joinSquad(identifier: string): Promise<SquadResponse> {
    const userInfo = AuthService.getUserInfo();
    if (!userInfo || !userInfo.id) {
      throw new Error('用户未登录或用户信息不完整');
    }
    
    const requestBody: JoinRequest = {
      userId: userInfo.id,
      identifier: identifier
    };
    
    return await NetworkService.post<SquadResponse>('/api/squads/join', requestBody);
  }

  /**
   * 获取小队信息的简化版本（不包含邀请码）
   * @param squad SquadResponse 完整的小队信息
   * @returns SquadResponse 简化的小队信息（移除了邀请码）
   */
  static getSquadLite(squad: SquadResponse): SquadResponse {
    // 创建一个新对象，复制所有属性，除了邀请码
    const squadLite: SquadResponse = {};
    
    // 手动复制属性，避免使用for...in
    if (squad.id !== undefined) squadLite.id = squad.id;
    if (squad.name !== undefined) squadLite.name = squad.name;
    if (squad.description !== undefined) squadLite.description = squad.description;
    if (squad.tags !== undefined) squadLite.tags = squad.tags;
    if (squad.maxMembers !== undefined) squadLite.maxMembers = squad.maxMembers;
    if (squad.currentMembers !== undefined) squadLite.currentMembers = squad.currentMembers;
    if (squad.status !== undefined) squadLite.status = squad.status;
    if (squad.ownerId !== undefined) squadLite.ownerId = squad.ownerId;
    if (squad.ownerUsername !== undefined) squadLite.ownerUsername = squad.ownerUsername;
    if (squad.allowIdJoin !== undefined) squadLite.allowIdJoin = squad.allowIdJoin;
    if (squad.memberIds !== undefined) squadLite.memberIds = squad.memberIds;
    
    return squadLite;
  }

  /**
   * 获取小队列表的简化版本（不包含邀请码）
   * @param squads Array<SquadResponse> 完整的小队列表
   * @returns Array<SquadResponse> 简化的小队列表（移除了邀请码）
   */
  static getSquadsLite(squads: Array<SquadResponse>): Array<SquadResponse> {
    return squads.map(squad => SquadService.getSquadLite(squad));
  }

  /**
   * 根据标签搜索小队
   * @param tag string 标签
   * @returns Promise<Array<SquadResponse>> 小队列表
   */
  static async searchByTag(tag: string): Promise<Array<SquadResponse>> {
    if (!tag.trim()) {
      throw new Error('标签不能为空');
    }
    // 直接传入tag字符串作为参数
    return await NetworkService.get<Array<SquadResponse>>(`/api/squads/search-by-tag`, tag);
  }

  /**
   * 根据标签搜索小队（简化版本，不包含邀请码）
   * @param tag string 标签
   * @returns Promise<Array<SquadResponse>> 小队列表
   */
  static async searchByTagLite(tag: string): Promise<Array<SquadResponse>> {
    if (!tag.trim()) {
      throw new Error('标签不能为空');
    }
    // 直接传入tag字符串作为参数
    return await NetworkService.get<Array<SquadResponse>>(`/api/squads/search-by-tag/lite`, tag);
  }
}
