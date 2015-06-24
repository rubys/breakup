require 'socket'
require 'sinatra'

# find an available socket
port = TCPServer.open('127.0.0.1', 0) {|server| server.addr[1]}

# start server
require_relative 'search/main'
set :port, port
set :views, '/var/www/web-platform/views'
server = fork {Rack::Builder.new {run Sinatra::Application}}

# capture web pages (html, js, json, css)
require 'net/http'
for i in 1..10
  begin
    Net::HTTP.start('localhost', port) do |http|
      File.write("search.html", http.get('/search').body)
      File.write("app.js", http.get('/app.js').body)
      File.write("index.json", http.get('/index.json').body)
      File.write("links.json", http.get('/links.json').body)
      File.write("doctitle.json", http.get('/doctitle.json').body)
      FileUtils.cp_r Dir['../search/public/*'], '.'
    end
    break
  rescue Errno::ECONNREFUSED
    sleep 0.1*i
  end
end

# terminate server
trap('INT') {exit}
Process.kill("INT", server)
Process.kill("INT", Process.pid)
