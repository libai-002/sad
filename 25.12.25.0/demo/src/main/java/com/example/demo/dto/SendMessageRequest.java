package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 发送消息请求
 * 用途：承载发送聊天消息所需的房间ID、发送者ID与内容
 * 使用说明：内容不能为空，服务层负责校验并持久化
 */
public class SendMessageRequest {
    @NotNull(message = "房间ID不能为空")
    private Long roomId;
    @NotNull(message = "发送者ID不能为空")
    private Long senderId;
    @NotBlank(message = "消息内容不能为空")
    private String content;

    public Long getRoomId() { return roomId; }
    public void setRoomId(Long roomId) { this.roomId = roomId; }
    public Long getSenderId() { return senderId; }
    public void setSenderId(Long senderId) { this.senderId = senderId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}
