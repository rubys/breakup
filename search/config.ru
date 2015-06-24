require File.expand_path('../main.rb', __FILE__)

set :public_folder, SPECS

run Sinatra::Application
