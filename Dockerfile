# 第一阶段：自动搜寻 JAR 包
FROM surveyking/surveyking:latest AS source

# 切换到 root 用户以确保有权限搜索
USER root

# 关键步骤：使用 find 命令查找 jar 包，并把它复制到一个固定位置 /core.jar
# 这样无论官方把文件藏在哪（/app, /opt, /survey），我们都能找到
RUN find / -name "survey-server.jar" -exec cp {} /core.jar \;

# 第二阶段：构建我们的伪装环境
FROM eclipse-temurin:17-jre-alpine

# 定义伪装名称
ENV APP_NAME=audit_core_module

# 从第一阶段的固定位置复制文件
COPY --from=source /core.jar /opt/${APP_NAME}.jar

# 设置工作目录
WORKDIR /opt

# 赋予权限
RUN chmod +x /opt/${APP_NAME}.jar

# 入口
ENTRYPOINT ["java", "-jar", "audit_core_module.jar"]
