package com.example.demo.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.HashMap;

@Service
/**
 * 微信 OAuth 服务
 * 用途：构建授权链接、换取令牌并拉取用户信息，未配置时提供 Demo 数据
 * 使用说明：通过配置文件注入 appId/appSecret/redirectBase；H5 与扫码模式分别支持
 */
public class WeChatOAuthService {
    @Value("${wechat.appid:}")
    private String appId;
    @Value("${wechat.appsecret:}")
    private String appSecret;
    @Value("${wechat.redirect-base:}")
    private String redirectBase;
    private final RestTemplate restTemplate = new RestTemplate();
    public boolean isConfigured() {
        return appId != null && !appId.isBlank() && appSecret != null && !appSecret.isBlank();
    }
    public String buildAuthorizeUrl(String mode, String redirect) {
        String callback = redirectBase + "/api/auth/wechat/callback";
        String encodedCallback = URLEncoder.encode(callback, StandardCharsets.UTF_8);
        String state = URLEncoder.encode(redirect == null ? "" : redirect, StandardCharsets.UTF_8);
        if (!isConfigured()) {
            return callback + "?code=DEMO&state=" + state;
        }
        if ("h5".equalsIgnoreCase(mode)) {
            return "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + appId + "&redirect_uri=" + encodedCallback + "&response_type=code&scope=snsapi_userinfo&state=" + state + "#wechat_redirect";
        } else {
            return "https://open.weixin.qq.com/connect/qrconnect?appid=" + appId + "&redirect_uri=" + encodedCallback + "&response_type=code&scope=snsapi_login&state=" + state;
        }
    }
    public Map<String, Object> exchangeCodeForToken(String code) {
        if (!isConfigured() || "DEMO".equalsIgnoreCase(code)) {
            Map<String, Object> demo = new HashMap<>();
            demo.put("openid", "demo_openid_" + java.util.UUID.randomUUID().toString().substring(0, 8));
            demo.put("access_token", "demo_access_token");
            return demo;
        }
        String url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + appId + "&secret=" + appSecret + "&code=" + code + "&grant_type=authorization_code";
        ResponseEntity<Map> resp = restTemplate.getForEntity(url, Map.class);
        return resp.getBody();
    }
    public Map<String, Object> getUserInfo(String accessToken, String openId) {
        if (!isConfigured() || accessToken.startsWith("demo_")) {
            Map<String, Object> demoInfo = new HashMap<>();
            demoInfo.put("unionid", "demo_unionid_" + java.util.UUID.randomUUID().toString().substring(0, 8));
            demoInfo.put("nickname", "微信用户");
            demoInfo.put("headimgurl", "https://avatars.githubusercontent.com/u/0?v=4");
            return demoInfo;
        }
        String url = "https://api.weixin.qq.com/sns/userinfo?access_token=" + accessToken + "&openid=" + openId + "&lang=zh_CN";
        ResponseEntity<Map> resp = restTemplate.getForEntity(url, Map.class);
        return resp.getBody();
    }
}
