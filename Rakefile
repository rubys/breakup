task "default" => ['specs', 'search']

task "specs" do
  rm_rf 'split' if Dir.exist? 'specs'
  sh 'node', 'splitter', '-c', 'split.json', '-o', 'specs'
end

task "search" do
  ruby 'capture.rb'
end

task 'clean' do
  rm_rf Dir['specs/*.js', 'specs/*.json', 'specs/search.html', 'specs/assets',
    'specs/stylesheets']
end
