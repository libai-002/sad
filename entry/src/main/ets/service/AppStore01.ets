/**
 * 应用状态管理（AppStore01）
 * 用于管理全局状态，如小队数据、用户状态等
 */

/**
 * 小队响应类型
 */
export interface SquadResponse {
  id?: number;
  name?: string;
  description?: string;
  tags?: string;
  maxMembers?: number;
  currentMembers?: number;
  status?: string;
  ownerId?: number;
  ownerUsername?: string;
  inviteCode?: string;
  allowIdJoin?: boolean;
  memberIds?: Array<number>;
}

/**
 * 操作结果类型
 */
export interface OperationResult {
  success: boolean;
  message: string;
}

/**
 * 退出小队请求类型
 */
export interface LeaveSquadRequest {
  userId: number;
  squadId: number;
}

/**
 * 加入小队请求类型
 */
export interface JoinRequest {
  userId: number;
  identifier: string;
}

export class AppStore01 {
  // 使用AppStorage存储状态，实现响应式管理
  private static readonly SQUADS_KEY = 'squads';
  private static readonly LOADING_KEY = 'loading';
  private static readonly NO_MORE_DATA_KEY = 'noMoreData';

  /**
   * 初始化存储
   */
  private static initializeStorage(): void {
    if (!AppStorage.has(AppStore01.SQUADS_KEY)) {
      AppStorage.setOrCreate(AppStore01.SQUADS_KEY, []);
    }
    if (!AppStorage.has(AppStore01.LOADING_KEY)) {
      AppStorage.setOrCreate(AppStore01.LOADING_KEY, false);
    }
    if (!AppStorage.has(AppStore01.NO_MORE_DATA_KEY)) {
      AppStorage.setOrCreate(AppStore01.NO_MORE_DATA_KEY, false);
    }
  }

  /**
   * 设置小队数据
   * @param squads 小队数据列表
   */
  public static setSquads(squads: Array<SquadResponse>): void {
    AppStore01.initializeStorage();
    AppStorage.set(AppStore01.SQUADS_KEY, squads);
  }

  /**
   * 获取小队数据
   * @returns 小队数据列表
   */
  public static getSquads(): Array<SquadResponse> {
    AppStore01.initializeStorage();
    return AppStorage.get(AppStore01.SQUADS_KEY) as Array<SquadResponse> || [];
  }

  /**
   * 添加小队数据
   * @param newSquads 新的小队数据列表
   */
  public static addSquads(newSquads: Array<SquadResponse>): void {
    AppStore01.initializeStorage();
    const currentSquads = AppStore01.getSquads();
    const updatedSquads = [...currentSquads, ...newSquads];
    AppStorage.set(AppStore01.SQUADS_KEY, updatedSquads);
  }

  /**
   * 清空小队数据
   */
  public static clearSquads(): void {
    AppStore01.initializeStorage();
    AppStorage.set(AppStore01.SQUADS_KEY, []);
  }

  /**
   * 设置加载状态
   * @param isLoading 是否正在加载
   */
  public static setLoading(isLoading: boolean): void {
    AppStore01.initializeStorage();
    AppStorage.set(AppStore01.LOADING_KEY, isLoading);
  }

  /**
   * 获取加载状态
   * @returns 是否正在加载
   */
  public static isLoading(): boolean {
    AppStore01.initializeStorage();
    return AppStorage.get(AppStore01.LOADING_KEY) as boolean || false;
  }

  /**
   * 设置无更多数据状态
   * @param noMore 是否无更多数据
   */
  public static setNoMoreData(noMore: boolean): void {
    AppStore01.initializeStorage();
    AppStorage.set(AppStore01.NO_MORE_DATA_KEY, noMore);
  }

  /**
   * 获取无更多数据状态
   * @returns 是否无更多数据
   */
  public static hasNoMoreData(): boolean {
    AppStore01.initializeStorage();
    return AppStorage.get(AppStore01.NO_MORE_DATA_KEY) as boolean || false;
  }

  /**
   * 重置状态
   */
  public static reset(): void {
    AppStore01.initializeStorage();
    AppStorage.set(AppStore01.SQUADS_KEY, []);
    AppStorage.set(AppStore01.LOADING_KEY, false);
    AppStorage.set(AppStore01.NO_MORE_DATA_KEY, false);
  }
}