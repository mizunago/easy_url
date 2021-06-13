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

def save_url(url)
  raise 'not support url' unless url.include?('rarethief')

  key = OpenSSL::Digest::SHA1.hexdigest(url)
  insert_sql = 'INSERT INTO easy_url VALUES(?, ?)'
  begin
    db.execute(insert_sql, key, url)
  rescue SQLite3::ConstraintException
    # 重複した場合に同じ URL か確認する
    select_sql = 'SELECT url FROM easy_url where hash = ?'
    # 同じ URL なら問題ないので抜ける
    db.execute(select_sql, key) do |row|
      raise "SHA1 is conflict.\nkey:#{key}\ndb value:     #{row[0]}\ninsert value: #{url}" if row[0] != url
    end
  end
  key
end

# sample
# key = save_url('https://maps.seaofthieves.rarethief.com/index.html?marker=landmark|Landmark|Barrel%20cart%20to%20the%20West|-6135.2529296875_7673.666015625')
# puts load_url(key)

get '/' do
  key = save_url(params['url']) unless params['url'].nil?
  redirect load_url(params['key']), 302 unless params['key'].nil?
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
    </body></html>
  HTML
end
