package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
/**
 * 搜索页面转发控制器
 * 用途：将 /search 请求转发到静态页面 search.html
 * 使用说明：用于简单页面导航，无业务逻辑
 */
public class SearchController {

    @GetMapping("/search")
    public String search() {
        return "forward:/search.html";
    }
}
