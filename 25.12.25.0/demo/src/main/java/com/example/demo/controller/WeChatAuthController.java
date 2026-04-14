package com.example.demo.controller;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.WeChatOAuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.view.RedirectView;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth/wechat")
/**
 * 微信认证控制器
 * 用途：提供授权跳转与回调处理，创建或登录用户
 * 使用说明：开发模式下返回模拟数据；支持携带 state 进行前端重定向
 */
public class WeChatAuthController {
    private final WeChatOAuthService weChatOAuthService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    public WeChatAuthController(WeChatOAuthService weChatOAuthService, UserRepository userRepository) {
        this.weChatOAuthService = weChatOAuthService;
        this.userRepository = userRepository;
    }
    @GetMapping("/authorize")
    public RedirectView authorize(@RequestParam(value = "redirect", required = false) String redirect, @RequestParam(value = "mode", required = false) String mode) {
        String url = weChatOAuthService.buildAuthorizeUrl(mode, redirect);
        return new RedirectView(url);
    }
    @GetMapping("/callback")
    public Object callback(@RequestParam("code") String code, @RequestParam(value = "state", required = false) String state) {
        Map<String, Object> token = weChatOAuthService.exchangeCodeForToken(code);
        if (token == null || token.get("openid") == null || token.get("access_token") == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "微信授权失败"));
        }
        String openId = String.valueOf(token.get("openid"));
        String accessToken = String.valueOf(token.get("access_token"));
        Map<String, Object> info = weChatOAuthService.getUserInfo(accessToken, openId);
        String unionId = info != null && info.get("unionid") != null ? String.valueOf(info.get("unionid")) : null;
        Optional<User> existing = unionId != null ? userRepository.findByWechatUnionId(unionId) : userRepository.findByWechatOpenId(openId);
        User user = existing.orElseGet(() -> {
            User u = new User();
            String base = unionId != null ? unionId : openId;
            String uname = "wx_" + base;
            String email = "wx_" + base + "@example.invalid";
            String pwd = passwordEncoder.encode(UUID.randomUUID().toString());
            u.setUsername(uname);
            u.setEmail(email);
            u.setPassword(pwd);
            u.setNickname(info != null && info.get("nickname") != null ? String.valueOf(info.get("nickname")) : uname);
            u.setAvatarUrl(info != null && info.get("headimgurl") != null ? String.valueOf(info.get("headimgurl")) : null);
            u.setWechatOpenId(openId);
            if (unionId != null) u.setWechatUnionId(unionId);
            return userRepository.save(u);
        });
        Map<String, Object> resp = new HashMap<>();
        resp.put("message", "登录成功");
        resp.put("userId", user.getId());
        resp.put("username", user.getUsername());
        resp.put("role", user.getRole());
        if (state != null && !state.isEmpty()) {
            return new RedirectView(state);
        }
        return ResponseEntity.ok(resp);
    }
}
