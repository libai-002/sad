package com.example.demo.controller;

import com.example.demo.dto.ChatMessageResponse;
import com.example.demo.dto.ChatRoomResponse;
import com.example.demo.dto.SendMessageRequest;
import com.example.demo.service.ChatService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
/**
 * 聊天控制器
 * 用途：提供按小队获取/创建聊天室、消息分页查询与发送接口
 * 使用说明：对请求参数执行校验；异常统一以 400 响应给前端
 */
public class ChatController {
    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @GetMapping("/room/by-squad/{squadId}")
    public ResponseEntity<?> getOrCreateRoom(@PathVariable Long squadId) {
        try {
            ChatRoomResponse room = chatService.getOrCreateRoomBySquad(squadId);
            return ResponseEntity.ok(room);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/messages/by-room/{roomId}")
    public ResponseEntity<?> listMessages(@PathVariable Long roomId,
                                          @RequestParam(defaultValue = "0") int page,
                                          @RequestParam(defaultValue = "50") int size) {
        try {
            List<ChatMessageResponse> messages = chatService.listMessages(roomId, page, size);
            return ResponseEntity.ok(messages);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/messages")
    public ResponseEntity<?> sendMessage(@Valid @RequestBody SendMessageRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error ->
                    errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }
        try {
            ChatMessageResponse msg = chatService.sendMessage(request.getRoomId(), request.getSenderId(), request.getContent());
            return ResponseEntity.ok(msg);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
