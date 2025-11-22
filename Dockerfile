# 第一阶段：智能搜寻源文件
FROM surveyking/surveyking:latest AS source

# 切换 Root 权限确保能读取所有目录
USER root

# 关键修改：
# 1. 使用 "*survey*.jar" 进行模糊匹配 (不管它是 surveyking.jar 还是 survey-server.jar)
# 2. 排除 /tmp 目录防止误判
# 3. 使用 head -n 1 只取第一个找到的主程序
# 4. 添加 ls -lh 检查，如果没找到文件，这步就会直接报错，方便调试
RUN TARGET_JAR=$(find / -type f -name "*survey*.jar" ! -path "/tmp/*" | head -n 1) && \
    echo "Found jar: $TARGET_JAR" && \
    cp "$TARGET_JAR" /core.jar && \
    ls -lh /core.jar

# 第二阶段：构建伪装环境
FROM eclipse-temurin:17-jre-alpine

ENV APP_NAME=audit_core_module

# 从第一阶段复制我们找到的文件
COPY --from=source /core.jar /opt/${APP_NAME}.jar

WORKDIR /opt

# 赋权
RUN chmod +x /opt/${APP_NAME}.jar

# 入口
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
