package com.example.demo.repository;

import com.example.demo.entity.ChatMessage;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * 聊天消息仓库
 * 用途：分页查询指定聊天室的消息，按时间升序返回
 * 使用说明：结合 Pageable 进行分页与大小控制
 */
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    Page<ChatMessage> findByRoom_IdOrderByCreatedAtAsc(Long roomId, Pageable pageable);
}
