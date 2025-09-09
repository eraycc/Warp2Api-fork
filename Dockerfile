# 使用官方 Python 3.13 镜像作为基础
FROM python:3.13-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOST=0.0.0.0 \
    PORT=8010 \
    BRIDGE_BASE_URL=http://localhost:8000 \
    PATH="/root/.local/bin:${PATH}"

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# 复制项目文件
COPY . .

# 使用 uv 安装依赖
RUN uv pip install --system -e .

# 暴露端口
EXPOSE 8000 8010

# 健康检查
HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8010/healthz || exit 1

# 启动命令 - 同时运行两个服务
CMD sh -c 'echo "Starting Protobuf Bridge Server..." && python server.py & \
           echo "Waiting for bridge server to start..." && sleep 5 && \
           echo "Starting OpenAI API Server..." && python openai_compat.py'
