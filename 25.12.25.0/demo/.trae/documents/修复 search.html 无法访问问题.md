## 问题判断
- 端口：当前以 --server.port=8081 运行，覆盖了 application.properties 的 8080，端口设置无问题。
- 安全：未引入 spring-boot-starter-security，也无安全配置类；静态页通常不会被拦截。
- 资源：/search.html 为静态资源，若当前运行的 JAR 未重新打包包含该文件，则会出现 404/无法访问。

## 解决方案
1. 同步端口配置
- 将 application.properties 的 server.port 修改为 8081，保持与运行一致，减少混淆。

2. 确认并打包静态资源
- 确保 search.html 位于 src/main/resources/static/ 下（已存在）。
- 执行 mvn clean package 重新打包，使新静态资源进入 demo-0.0.1-SNAPSHOT.jar。

3. 重启应用
- 停止当前运行的 JAR，使用新打包的 JAR 重新启动（端口：8081）。
- 验证 http://localhost:8081/search.html 可正常访问。

4. 统一路由体验（可选优化）
- 增加一个控制器，将 /search 映射到 search.html，便于无扩展名访问。
- 保留现有的 /search/index.html 结果页，search.html 在有 q 参数时自动跳转。

5. 未来引入安全时的白名单（预防性措施）
- 若后续添加 Spring Security：对 "/*.html"、"/css/**"、"/js/**"、"/images/**" 等静态资源 permitAll，避免误拦截。

## 验证步骤
- 浏览器访问 http://localhost:8081/search.html（无参数应显示搜索首页）。
- 在顶部输入框回车跳转到 http://localhost:8081/search.html?q=关键词，再自动进入 /search/index.html 展示结果。
- 从 dashboard 顶部搜索框直接回车亦应到达上述流程。