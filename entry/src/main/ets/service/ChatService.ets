import { NetworkService } from './NetworkService';

/**
 * 聊天室响应类型
 */
export interface ChatRoomResponse {
  id?: number;
  squadId?: number;
  createdAt?: string;
}

/**
 * 聊天消息响应类型
 */
export interface ChatMessageResponse {
  id?: number;
  roomId?: number;
  senderId?: number;
  senderName?: string;
  content?: string;
  timestamp?: string;
}

/**
 * 聊天服务
 * 处理聊天相关的后端接口调用
 */
export class ChatService {
  /**
   * 通过小队ID获取或创建聊天室
   * @param squadId number 小队ID
   * @returns Promise<ChatRoomResponse> 聊天室信息
   */
  static async getOrCreateRoomBySquad(squadId: number): Promise<ChatRoomResponse> {
    return await NetworkService.get<ChatRoomResponse>(`/api/chat/room/by-squad/${squadId}`);
  }

  /**
   * 通过聊天室ID获取聊天消息
   * @param roomId number 聊天室ID
   * @param page number 页码，默认0
   * @param size number 每页数量，默认50
   * @returns Promise<Array<ChatMessageResponse>> 聊天消息列表
   */
  static async getMessagesByRoomId(roomId: number, page: number = 0, size: number = 50): Promise<Array<ChatMessageResponse>> {
    return await NetworkService.get<Array<ChatMessageResponse>>(`/api/chat/messages/by-room/${roomId}?page=${page}&size=${size}`);
  }
}