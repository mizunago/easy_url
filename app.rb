#!/home/ubuntu/.rbenv/versions/2.7.3/bin/ruby
# #!/usr/bin/ruby
# encoding: utf-8

require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext'
require 'sinatra'
require 'sqlite3'
require 'openssl'

def db
  _db = SQLite3::Database.new('db/url.db')
  sql = <<-SQL
    create table easy_url (
      hash text primary key,
      url text
    );
  SQL

  begin
    _db.execute(sql)
  rescue SQLite3::SQLException => e
    raise if e.message != 'table easy_url already exists'
  end
  _db
end

def load_url(key)
  select_sql = 'SELECT url FROM easy_url where hash = ?'
  db.execute(select_sql, key) do |row|
    return row[0]
  end
  nil
end

def save_url(key, url)
  raise 'not support url' unless url.include?('https://maps.seaofthieves.rarethief.com/index.html')

  insert_sql = 'INSERT INTO easy_url VALUES(?, ?)'
  db.execute(insert_sql, key, url)
  key
end

def save_url_wrap(url)
  key = OpenSSL::Digest::SHA1.hexdigest(url)
  is_new = true
  begin
    save_url(key, url)
  rescue SQLite3::ConstraintException
    # 重複した場合に同じ URL か確認する
    select_sql = 'SELECT url FROM easy_url where hash = ?'
    # 同じ URL なら問題ないので抜ける
    db.execute(select_sql, key) do |row|
      if row[0] == url
        is_new = false
      else
        raise "SHA1 is conflict.\nkey:#{key}\ndb value:     #{row[0]}\ninsert value: #{url}"
      end
    end
  end
  [key, is_new]
end

def list_url
  html = ['<table>', '<tr>', '<th>key</th>', '<th>url</th>', '</tr>']
  select_sql = 'SELECT hash, url FROM easy_url'
  db.execute(select_sql) do |row|
    html << "<tr><td>#{row[0]}</td><td><a href=\"#{row[1]}\">url</a></td></tr>"
  end
  html << '</table>'
  html.join
end

# sample
# key = save_url('https://maps.seaofthieves.rarethief.com/index.html?marker=landmark|Landmark|Barrel%20cart%20to%20the%20West|-6135.2529296875_7673.666015625')
# puts load_url(key)

get '/' do
  key, is_new = save_url_wrap(params['url']) unless params['url'].nil?
  redirect load_url(params['key']), 302 unless params['key'].nil?
  list = list_url unless params['list'].nil?
  html = <<~HTML
    <html>
    <head><title>短縮URL作成</title></head><body>
    <form>
    <input type="text" name="url" size="220">
    <input type="submit">
    <br />
    <br />
    <br />
    #{key ? '<a href="https://sot.nagonago.tv/cgi/url/index.rb?key=' + key + '">Copy me</a>' : ''}
    </form>
    #{is_new ? '新規登録' : 'すでに登録済み'}<br />
    #{list}
    </body></html>
  HTML
end
