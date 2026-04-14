## 改动概要
- 在后端新增“推荐小队”接口：inviteCode 为 NULL，按随机顺序返回，最多 8 条
- 在前端 dashboard.html 的“推荐小队”区动态加载接口数据，渲染卡片：名字、内容、标签、当前人数/总人数
- 默认展示 8 条，允许通过 URL limit 参数（<=8）控制上限

## 相关位置
- 前端页面： [dashboard.html](file:///c:/Users/75814/Desktop/桌面001/25.12.25.0/demo/src/main/resources/static/dashboard.html)
- 控制器： [SquadController.java](file:///c:/Users/75814/Desktop/桌面001/25.12.25.0/demo/src/main/java/com/example/demo/controller/SquadController.java)
- 服务层： [SquadService.java](file:///c:/Users/75814/Desktop/桌面001/25.12.25.0/demo/src/main/java/com/example/demo/service/SquadService.java)
- 仓库： [SquadRepository.java](file:///c:/Users/75814/Desktop/桌面001/25.12.25.0/demo/src/main/java/com/example/demo/repository/SquadRepository.java)
- 实体与DTO： [Squad.java](file:///c:/Users/75814/Desktop/桌面001/25.12.25.0/demo/src/main/java/com/example/demo/entity/Squad.java)、[SquadResponse.java](file:///c:/Users/75814/Desktop/桌面001/25.12.25.0/demo/src/main/java/com/example/demo/dto/SquadResponse.java)

## 后端实现
- 仓库新增原生查询（MySQL）：invite_code IS NULL 随机排序并限制条数
```java
@Query(value = "SELECT * FROM squads WHERE invite_code IS NULL ORDER BY RAND() LIMIT :limit", nativeQuery = true)
List<Squad> findRandomRecommended(@Param("limit") int limit);
```
- 服务层新增方法：
```java
@Transactional(readOnly = true)
public List<SquadResponse> listRecommended(int limit) {
    int capped = (limit <= 0 || limit > 8) ? 8 : limit;
    return squadRepository.findRandomRecommended(capped)
            .stream().map(this::toResponse).collect(Collectors.toList());
}
```
- 控制器新增接口：
```java
@GetMapping("/api/squads/recommended")
public List<SquadResponse> recommended(@RequestParam(defaultValue = "8") Integer limit) {
    return squadService.listRecommended(limit == null ? 8 : limit);
}
```

## 前端实现（dashboard.html）
- 保留现有结构与样式类（.squad-grid、.squad-card 等），将静态卡片替换为 JS 动态渲染
- 页面加载时请求 `/api/squads/recommended?limit=8`，生成卡片：
```html
<script>
document.addEventListener('DOMContentLoaded', async () => {
  const grid = document.querySelector('.squad-grid');
  grid.innerHTML = '';
  const resp = await fetch('/api/squads/recommended?limit=8');
  const list = await resp.json();
  list.forEach(s => {
    const full = (s.currentMembers != null && s.maxMembers != null && s.currentMembers >= s.maxMembers);
    const statusText = full ? '满员' : '招募中';
    const btnText = full ? '已满员' : '申请加入';
    const btnDisabled = full ? 'disabled' : '';
    const tags = (s.tags || '').split(/[，,\s]+/).filter(Boolean);
    const card = document.createElement('div');
    card.className = 'squad-card';
    card.innerHTML = `
      <div class="squad-cover"><div class="squad-status ${full ? '' : 'recruiting'}">${statusText}</div></div>
      <div class="squad-body">
        <div class="squad-name">${s.name || ''}</div>
        <div class="squad-desc">${s.description || ''}</div>
        <div class="squad-tags">${tags.map(t => `<span class='tag-mini'>${t}</span>`).join('')}</div>
        <div class="squad-meta"><span> ${s.currentMembers || 0}/${s.maxMembers || 0} 人</span></div>
        <button class="btn-primary" ${btnDisabled}>${btnText}</button>
      </div>`;
    grid.appendChild(card);
  });
  if (!list.length) {
    const empty = document.createElement('div');
    empty.style.color = '#888';
    empty.textContent = '暂无推荐小队';
    grid.appendChild(empty);
  }
});
</script>
```
- 随机化由后端 `ORDER BY RAND()` 保证，前端不再二次乱序

## 校验与边界
- 数据库已配置 MySQL，`RAND()` 适配当前方言 [application.properties](file:///c:/Users/75814/Desktop/桌面001/25.12.25.0/demo/src/main/resources/application.properties#L4-L10)
- 邀请码过滤：仅返回 `inviteCode == null` 的记录
- 限制条数：最大 8；当 limit 超出或非法时按 8 处理
- 满员判定：`currentMembers >= maxMembers` 则展示“满员”并禁用按钮

## 结果
- dashboard 的“推荐小队”展示来自数据库的实时数据：名字、内容、标签、当前/总人数
- 随机显示且最多 8 项，满足“邀请码为 null”的限制