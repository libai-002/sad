package com.example.demo.controller;

import com.example.demo.dto.RegisterRequest;
import com.example.demo.dto.LoginRequest;
import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import com.example.demo.service.UserHistoryService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
/**
 * 认证控制器
 * 用途：处理注册、登录、忘记/重置密码的 HTTP 请求
 * 使用说明：入参使用 @Valid 进行校验；异常以 400 返回错误信息给前端
 */
public class AuthController {

    private final UserService userService;
    private final UserHistoryService userHistoryService;

    public AuthController(UserService userService, UserHistoryService userHistoryService) {
        this.userService = userService;
        this.userHistoryService = userHistoryService;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request, BindingResult result) {
        // 参数校验失败处理
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error -> 
                errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }

        try {
            User newUser = userService.registerUser(request);
            Map<String, Object> response = new HashMap<>();
            response.put("message", "注册成功");
            response.put("userId", newUser.getId());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error -> 
                errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }

        try {
            User user = userService.loginUser(request);
            // 登录成功后重置用户的历史记录，这样每次登录都会看到新的随机小队
            userHistoryService.clearHistory(user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("message", "登录成功");
            response.put("userId", user.getId());
            response.put("username", user.getUsername());
            response.put("role", user.getRole());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/forgot")
    public ResponseEntity<?> forgot(@Valid @RequestBody com.example.demo.dto.ForgotPasswordRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error -> 
                errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }
        try {
            String token = userService.initiatePasswordReset(request.getIdentity());
            return ResponseEntity.ok(Map.of("message", "重置令牌已发送", "tokenDemo", token));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/reset")
    public ResponseEntity<?> reset(@Valid @RequestBody com.example.demo.dto.ResetPasswordRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error -> 
                errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }
        try {
            userService.resetPassword(request.getIdentity(), request.getToken(), request.getNewPassword());
            return ResponseEntity.ok(Map.of("message", "密码已重置"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
