package com.example.demo;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

@SpringBootTest
public class DbInspector {

    @Autowired
    private UserRepository userRepository;

    @Test
    public void printAllUsers() {
        try {
            List<User> users = userRepository.findAll();
            System.out.println("\n\n====== 数据库当前内容 (Database Content) ======");
            System.out.println("数据库连接状态: 正常");
            System.out.println("当前用户数量: " + users.size());
            if (users.isEmpty()) {
                System.out.println("表 'users' 为空。");
            } else {
                System.out.printf("%-5s %-15s %-25s %-10s%n", "ID", "Username", "Email", "Role");
                System.out.println("----------------------------------------------------------");
                for (User user : users) {
                    System.out.printf("%-5d %-15s %-25s %-10s%n", 
                        user.getId(), 
                        user.getUsername(), 
                        user.getEmail(), 
                        user.getRole());
                }
            }
            System.out.println("==============================================\n");
        } catch (Exception e) {
            System.out.println("\n\n====== 数据库检查失败 ======");
            System.out.println("错误信息: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
