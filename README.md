# 短縮されてるのかよくわかんない URL を作るやつ

基本的に無サポート。自分用なので

## インストール方法・動かし方

- spawn-fcgi, fcgiwrap をインストールして nginx で動かせるように設定する
  - [参考:fcgiwrapをインストールしてNginxでCGIを動かす](https://worklog.be/archives/3230)
- nginx で設定する
```
# ※ スクリプトが /home/www/default/html/cgi/url/ にある場合
location /cgi/ {
  root /home/www/default/html;
  include /etc/nginx/fcgiwrap.conf;
}
```
- index.rb, app.rb を修正する
  - 特に1行目は環境依存の書き方をしているので修正必須
- gem を bundle してインストールする(以下のどちらか。rbenv 使ってる場合は前者)
  - `rbenv exec bundle`
  - `bundle`
- とりあえず、gem とか入ってるか、ruby が動いてるかどうか確認したいなら
  - `rbenv exec bundle exec ruby app.rb`
  - `bundle exec ruby app.rb`
- 動作確認する
  - http://example.com/cgi/url/index.rb


## 構成要素と注意点

- index.rb
  - マウントポイント
  - 1行目は環境に合わせて修正してください
  - rbenv で ruby 2.7.3 を入れている想定で書かれています
- app.rb
  - メインプログラム
  - 1行目は環境に合わせて修正してください
  - rbenv で ruby 2.7.3 を入れている想定で書かれています
- db/url.db
  - db ディレクトリはパーミッションを 777 にしてください。
  - url.db はパーミッションを 666 にしてください。
