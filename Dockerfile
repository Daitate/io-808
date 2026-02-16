# --- Build Stage ---
# 互換性の高いDebianベースのNode 14を使用
FROM node:14-buster as build

WORKDIR /app

# 依存関係ファイルをコピー
COPY package*.json yarn.lock ./

# 依存関係のインストール（--forceで警告を無視して強制実行）
RUN npm install --legacy-peer-deps --force

# ソースコードをコピー
COPY . .

# 環境変数をセットしてビルド（CI=falseで警告による停止を防ぐ）
ENV CI=false
RUN npm run build

# --- Production Stage ---
# ビルド成果物をNginxで配信
FROM nginx:alpine

# Nginxの公開フォルダにビルド済みファイルを配置
COPY --from=build /app/build /usr/share/nginx/html

# ポート80を開放
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
