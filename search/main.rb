#!/usr/bin/ruby2.2
require 'wunderbar/sinatra'
require 'wunderbar/react'
require 'ruby2js/filter/functions'
require 'nokogumbo'

SPECS = File.expand_path('../../specs', __FILE__)

# determine the title for the section containing the given element
def title(element)
  parent = element.parent
  title = nil

  while parent
    if parent.name =~ /^h\d/
      title = parent
      break
    elsif parent.name == 'section'
      if parent.first_element_child.name =~ /^h\d/
        title = parent.first_element_child
        break
      end
    end
    parent = (parent.parent if parent.respond_to? :parent)
  end

  if title and not title['id']
    title['id'] = title.text.downcase.gsub(/\W+/, '-')
  end

  title
end

# parse specs for definitions and links
Dir.chdir SPECS
index = Hash.new {|hash, key| hash[key] = Array.new}
links = Hash.new {|hash, key| hash[key] = Array.new}
doctitle = {}
Dir['*/index.html'].each do |spec|
  # parse spec
  base = File.dirname(spec)
  doc = Nokogiri::HTML5(IO.read spec)

  # extract title
  doctitle[base] = doc.at('title').text

  # index sections that start with a header
  doc.search('section').each do |section|
    header = section.first_element_child
    next unless header.name =~ /^h[1-6]$/
    id = header['id'] || "h-#{header.text}".downcase.gsub(/\W+/, '-')
    value = {text: header.text, id: id}
    index[header.text.gsub(/\s+/, ' ')] << [value, base, id]
  end

  # index dfn's
  doc.search('dfn').each do |dfn|
    id = dfn['id'] || "dfn-#{dfn.text}".downcase.gsub(/\W+/, '-')
    value = title(dfn)
    value = {text: value.text, id: value['id']} if value
    index[dfn.text.gsub(/\s+/, ' ')] << [value, base, id]
  end

  # index code
  groups = ["node", "interface", "exception", "IDL attribute", "method",
    "event", "object", "attribute", "element"]
  doc.search('code').each do |code|
    id = code['id']
    next unless id

    text = code.text

    # append next word from text if a recognized group
    node = code.next
    if node and node.text?
      word = node.text.strip.split.first.to_s.sub(/\W?s?\W*$/, '')
      if word == 'IDL'
        word = node.text[/(IDL\s+\w+?)s?\b/, 1].to_s.sub(/\s+/, ' ')
      end
      text += ' ' + word if groups.include? word
    end

    value = title(code)
    value = {text: value.text, id: value['id']} if value
    index[text.gsub(/\s+/, ' ')] << [value, base, id]
  end

  # capture links
  doc.search('a').each do |a|
    href = a['href']
    section = title(a)
    next unless section
    section = {text: section.text, id: section['id']}
    if href.start_with? '#'
      links["#{base}/#{href}"] << [section, base]
    elsif href.start_with? '/breakup/specs/'
      links[href[15..-1]] << [section, base]
    end
  end
end

# sort index values
index.each do |text, values|
  values.sort_by! {|title, doc, link| "#{title[:text]} - #{doctitle[doc]}"}
  [text, values]
end

# dedupe, sort, and cleanup links
links.each do |key, values|
  # remove self and unresolved links
  values.delete_if do |section, base| 
    section == nil or key == "#{base}/##{section[:id]}"
  end

  # sort by title
  values.sort_by! {|section, base| "#{doctitle[base]} - #{section[:text]}"}

  # select unique links
  links[key] = values.uniq
end

# produce web page
get '/search' do
  _html :main
end

get '/index.json' do
  headers "Content-Type" => "application/json; charset=utf-8"
  JSON.dump index.to_a.sort_by {|key, value| key.downcase}
end

get '/links.json' do
  headers "Content-Type" => "application/json; charset=utf-8"
  JSON.dump links
end

get '/doctitle.json' do
  headers "Content-Type" => "application/json; charset=utf-8"
  JSON.dump doctitle
end

# resolve directories to static index.html files
get '/' do
  call env.merge "PATH_INFO" => "/index.html"
end

get %r{^/([-\w]+)/$} do |spec|
  call env.merge "PATH_INFO" => "/#{spec}/index.html"
end

# other static files
get %r{(.*)} do |file|
  file = File.expand_path("../public/#{file}", __FILE__)
  pass unless File.exist? file
  send_file file
end
