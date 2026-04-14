package com.example.demo.dto;

import java.time.LocalDateTime;

/**
 * 聊天室响应
 * 用途：返回聊天室的标识、名称、关联小队及创建时间
 * 使用说明：用于前端进入指定小队的聊天上下文
 */
public class ChatRoomResponse {
    private Long id;
    private String name;
    private Long squadId;
    private LocalDateTime createdAt;

    public ChatRoomResponse() {}

    public ChatRoomResponse(Long id, String name, Long squadId, LocalDateTime createdAt) {
        this.id = id;
        this.name = name;
        this.squadId = squadId;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Long getSquadId() { return squadId; }
    public void setSquadId(Long squadId) { this.squadId = squadId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
