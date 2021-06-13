#!/home/ubuntu/.rbenv/versions/2.7.3/bin/ruby

APP_HOME = __dir__.freeze
load "#{APP_HOME}/app.rb"
set :run, false

Rack::Handler::CGI.run Sinatra::Application
