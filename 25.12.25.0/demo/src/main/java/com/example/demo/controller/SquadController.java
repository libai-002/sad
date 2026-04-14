package com.example.demo.controller;
import com.example.demo.dto.CreateSquadRequest;
import com.example.demo.dto.SquadResponse;
import com.example.demo.dto.LiteSquadResponse;
import com.example.demo.dto.JoinSquadRequest;
import com.example.demo.dto.JoinByIdRequest;
import com.example.demo.dto.JoinRequest;
import com.example.demo.dto.LeaveSquadRequest;
import com.example.demo.dto.LeaveByIdRequest;
import com.example.demo.service.SquadService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/squads")
/**
 * 小队控制器
 * 用途：提供小队的创建、加入/退出、邀请码管理、搜索与推荐等接口
 * 使用说明：所有输入均进行校验；业务逻辑由 SquadService 负责处理
 */
public class SquadController {

    private final SquadService squadService;

    public SquadController(SquadService squadService) {
        this.squadService = squadService;
    }

    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody CreateSquadRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error ->
                    errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }
        try {
            SquadResponse created = squadService.createSquad(request);
            return ResponseEntity.ok(created);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/by-owner/{ownerId}")
    public ResponseEntity<?> listByOwner(@PathVariable Long ownerId) {
        try {
            List<SquadResponse> squads = squadService.listByOwner(ownerId);
            return ResponseEntity.ok(squads);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/by-id/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        try {
            SquadResponse s = squadService.getById(id);
            return ResponseEntity.ok(s);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/joined/{userId}")
    public ResponseEntity<?> listJoined(@PathVariable Long userId) {
        try {
            List<SquadResponse> squads = squadService.listJoined(userId);
            return ResponseEntity.ok(squads);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/join/by-id")
    public ResponseEntity<?> joinById(@Valid @RequestBody JoinByIdRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error ->
                    errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }
        try {
            SquadResponse s = squadService.joinById(request.getUserId(), request.getSquadId());
            return ResponseEntity.ok(s);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/join/by-code")
    public ResponseEntity<?> joinByCode(@Valid @RequestBody com.example.demo.dto.JoinByCodeRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error ->
                    errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }
        try {
            SquadResponse s = squadService.joinByInviteCode(request.getUserId(), request.getInviteCode());
            return ResponseEntity.ok(s);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/join")
    public ResponseEntity<?> join(@Valid @RequestBody JoinRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error ->
                    errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }
        try {
            SquadResponse s = squadService.join(request.getUserId(), request.getIdentifier());
            return ResponseEntity.ok(s);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/leave/by-id")
    public ResponseEntity<?> leaveById(@Valid @RequestBody LeaveByIdRequest request, BindingResult result) {
        if (result.hasErrors()) {
            Map<String, String> errors = new HashMap<>();
            result.getFieldErrors().forEach(error ->
                    errors.put(error.getField(), error.getDefaultMessage())
            );
            return ResponseEntity.badRequest().body(errors);
        }
        try {
            squadService.leaveById(request.getUserId(), request.getSquadId());
            return ResponseEntity.ok(Map.of("message", "退出成功"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/invite/{id}/generate")
    public ResponseEntity<?> generateInvite(@PathVariable Long id) {
        try {
            SquadResponse s = squadService.generateInviteCode(id);
            return ResponseEntity.ok(s);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/{id}/id-join")
    public ResponseEntity<?> setIdJoin(@PathVariable Long id, @RequestParam boolean allow) {
        try {
            SquadResponse s = squadService.setAllowIdJoin(id, allow);
            return ResponseEntity.ok(s);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/search-by-tag")
    public ResponseEntity<?> searchByTag(@RequestParam String tag) {
        try {
            List<SquadResponse> squads = squadService.searchByTagEquals(tag);
            return ResponseEntity.ok(squads);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/recommended")
    public ResponseEntity<?> recommended(@RequestParam(required = false, defaultValue = "8") Integer limit) {
        try {
            List<SquadResponse> squads = squadService.listRecommended(limit == null ? 8 : limit);
            return ResponseEntity.ok(squads);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    @GetMapping("/random-unique")
    public ResponseEntity<?> getRandomUniqueSquads(@RequestParam Long userId, @RequestParam(required = false, defaultValue = "4") Integer limit) {
        try {
            List<SquadResponse> squads = squadService.getRandomUniqueSquads(userId, limit == null ? 4 : limit);
            return ResponseEntity.ok(squads);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/random-unique/lite")
    public ResponseEntity<?> getRandomUniqueSquadsLite(@RequestParam Long userId, @RequestParam(required = false, defaultValue = "4") Integer limit) {
        try {
            List<LiteSquadResponse> squads = squadService.getRandomUniqueSquadsLite(userId, limit == null ? 4 : limit);
            return ResponseEntity.ok(squads);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/recommended/lite")
    public ResponseEntity<?> recommendedLite(@RequestParam(required = false, defaultValue = "8") Integer limit) {
        try {
            List<LiteSquadResponse> squads = squadService.listRecommendedLite(limit == null ? 8 : limit);
            return ResponseEntity.ok(squads);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/search-by-tag/lite")
    public ResponseEntity<?> searchByTagLite(@RequestParam String tag) {
        try {
            List<LiteSquadResponse> squads = squadService.searchByTagEqualsLite(tag);
            return ResponseEntity.ok(squads);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}