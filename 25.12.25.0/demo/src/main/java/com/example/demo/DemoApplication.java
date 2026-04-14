package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 应用入口类
 * 用途：启动 Spring Boot 应用，加载配置并初始化各层组件
 * 使用说明：运行 main 方法即可启动服务（开发环境默认端口参见配置文件）
 */
@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}

}
