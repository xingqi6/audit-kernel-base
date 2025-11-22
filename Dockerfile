# 1. 临时阶段：使用官方镜像作为源
FROM surveyking/surveyking:latest AS source

# 2. 最终阶段：构建我们的伪装环境
# 注意：SurveyKing 较新版本建议使用 Java 17
FROM eclipse-temurin:17-jre-alpine

# 定义伪装名称
ENV APP_NAME=audit_core_module

# 直接从官方镜像中把 Jar 包复制出来，改名
# 这样就绝对不会出现下载失败或文件损坏的问题
COPY --from=source /survey-server.jar /opt/${APP_NAME}.jar

# 设置工作目录
WORKDIR /opt

# 赋予执行权限
RUN chmod +x /opt/${APP_NAME}.jar

# 默认入口
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
