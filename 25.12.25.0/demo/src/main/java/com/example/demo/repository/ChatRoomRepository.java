package com.example.demo.repository;

import com.example.demo.entity.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

/**
 * 聊天室仓库
 * 用途：提供聊天室的持久化访问与按小队查找
 * 使用说明：findBySquad_Id 通过外键字段查询指定小队的聊天室
 */
public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    Optional<ChatRoom> findBySquad_Id(Long squadId);
}
