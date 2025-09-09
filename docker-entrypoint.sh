#!/bin/bash
set -e

# 等待桥接服务器启动（如果同时启动两个服务）
if [ "$1" = "both" ]; then
    # 启动桥接服务器（后台运行）
    echo "Starting Protobuf Bridge Server..."
    python server.py &
    BRIDGE_PID=$!
    
    # 等待桥接服务器就绪
    echo "Waiting for bridge server to be ready..."
    sleep 5
    
    # 启动 OpenAI API 服务器（前台运行）
    echo "Starting OpenAI API Server..."
    exec python openai_compat.py
    
    # 清理
    kill $BRIDGE_PID
else
    # 只启动指定的服务
    exec "$@"
fi
