# Node v10を使用（このアプリの開発当時のバージョン）
FROM node:10-buster as build

WORKDIR /app

# gitが必要なためインストール
RUN apt-get update && apt-get install -y git

# 依存関係ファイルをコピー
COPY package.json yarn.lock ./

# yarnを使ってインストール（npmより互換性が高い）
# ignore-enginesでバージョンの不一致を無視
RUN yarn install --ignore-engines

# ソースコードをコピー
COPY . .

# 環境変数をセットしてビルド
ENV CI=false
RUN yarn build

# --- Production Stage ---
FROM nginx:alpine

# ビルド成果物をNginxの公開フォルダにコピー
COPY --from=build /app/build /usr/share/nginx/html

# ポート80を開放
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
