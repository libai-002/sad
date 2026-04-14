package com.example.demo.service;

import com.example.demo.dto.ChatMessageResponse;
import com.example.demo.dto.ChatRoomResponse;
import com.example.demo.entity.ChatMessage;
import com.example.demo.entity.ChatRoom;
import com.example.demo.entity.Squad;
import com.example.demo.entity.User;
import com.example.demo.repository.ChatMessageRepository;
import com.example.demo.repository.ChatRoomRepository;
import com.example.demo.repository.SquadRepository;
import com.example.demo.repository.UserRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
/**
 * 聊天业务服务
 * 用途：按小队维度创建/获取聊天室，提供消息分页查询与发送能力
 * 使用说明：发送消息校验内容非空；分页查询按时间升序返回，便于前端展示
 */
public class ChatService {
    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final SquadRepository squadRepository;
    private final UserRepository userRepository;

    public ChatService(ChatRoomRepository chatRoomRepository, ChatMessageRepository chatMessageRepository,
                       SquadRepository squadRepository, UserRepository userRepository) {
        this.chatRoomRepository = chatRoomRepository;
        this.chatMessageRepository = chatMessageRepository;
        this.squadRepository = squadRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public ChatRoomResponse getOrCreateRoomBySquad(Long squadId) {
        Squad s = squadRepository.findById(squadId).orElseThrow(() -> new RuntimeException("小队不存在"));
        ChatRoom room = chatRoomRepository.findBySquad_Id(squadId).orElseGet(() -> {
            ChatRoom r = new ChatRoom();
            r.setSquad(s);
            r.setName(s.getName());
            return chatRoomRepository.save(r);
        });
        return new ChatRoomResponse(room.getId(), room.getName(), room.getSquad().getId(), room.getCreatedAt());
    }

    @Transactional(readOnly = true)
    public List<ChatMessageResponse> listMessages(Long roomId, int page, int size) {
        List<ChatMessage> msgs = chatMessageRepository
                .findByRoom_IdOrderByCreatedAtAsc(roomId, PageRequest.of(page, size))
                .getContent();
        return msgs.stream().map(m -> new ChatMessageResponse(
                m.getId(),
                m.getRoom().getId(),
                m.getSender().getId(),
                m.getSender().getUsername(),
                m.getContent(),
                m.getCreatedAt()
        )).collect(Collectors.toList());
    }

    @Transactional
    public ChatMessageResponse sendMessage(Long roomId, Long senderId, String content) {
        ChatRoom room = chatRoomRepository.findById(roomId).orElseThrow(() -> new RuntimeException("房间不存在"));
        User sender = userRepository.findById(senderId).orElseThrow(() -> new RuntimeException("用户不存在"));
        if (content == null || content.isBlank()) {
            throw new RuntimeException("消息内容不能为空");
        }
        ChatMessage msg = new ChatMessage();
        msg.setRoom(room);
        msg.setSender(sender);
        msg.setContent(content);
        ChatMessage saved = chatMessageRepository.save(msg);
        return new ChatMessageResponse(saved.getId(), roomId, senderId, sender.getUsername(), saved.getContent(), saved.getCreatedAt());
    }
}
