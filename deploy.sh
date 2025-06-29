#!/bin/bash

# === 配置项 ===
NAS_USER="keepdying44"
NAS_IP="192.168.31.44"
NAS_PATH="/vol2/1000/theshade"
CONTAINER_NAME="hugo-blog"

# === 第一步：构建 Hugo 博客 ===
echo ">> 正在构建 Hugo 博客..."
hugo
if [ $? -ne 0 ]; then
  echo "!! Hugo 构建失败"
  exit 1
fi

# === 第二步：上传到 NAS ===
echo ">> 正在上传博客到 NAS..."
rsync -avz --delete ./public/ ${NAS_USER}@${NAS_IP}:${NAS_PATH}/
if [ $? -ne 0 ]; then
  echo "!! 上传失败"
  exit 1
fi

# === 第三步：重启 Docker 容器 ===
echo ">> 正在重启 NAS 上的 Docker 容器（${CONTAINER_NAME}）..."
ssh ${NAS_USER}@${NAS_IP} "sudo docker restart ${CONTAINER_NAME}"
if [ $? -ne 0 ]; then
  echo "!! 容器重启失败"
  exit 1
fi

echo "✅ 部署完成！你现在可以访问 http://${NAS_IP}:8080 查看博客"
