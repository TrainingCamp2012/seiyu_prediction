# -*- coding: utf-8 -*-
# crawl SEIYU lists from wikipedia
require "nokogiri"
require "open-uri"
require "kconv"

class Crawler
  attr_reader :seiyus
  def initialize
    @seiyus = Array.new
    @base_url = "http://ja.wikipedia.org"
  end

  def get_list(url)
    url = @base_url + url
    puts "Now: #{url}"
    doc = Nokogiri::HTML(open(url).read)
    (doc/"div#mw-pages"/"li").each do |e|
      @seiyus.push e.inner_text
    end
    
    if new_url = next_url(doc)
      sleep 5
      get_list(new_url)
    end
  end
  
  def next_url(doc)
    url = nil
    (doc/"div#mw-pages"/"a").each do |e|
      url = e[:href] if e.inner_text.include?("次の200件")
    end
    url
  end
end

class Array
  # 声優個人板のスレタイに含まれているもののみ出力する
  def filtering_2ch
    url = "http://ikura.2ch.net/voiceactor/subback.html"
    d = Nokogiri::HTML(open(url).read)

    threads = Array.new
    (d/"a").each do |e|
      threads.push e.inner_text.toutf8
    end
    
    filterd_lists = Array.new
    
    self.each do |name|
      threads.each do |title|
        if title.include?(name)
          filterd_lists.push name
          next
        end
      end
    end
    filterd_lists
  end
  
end

if $0 == __FILE__
  d = Crawler.new
  # 男性声優の場合は
  url = "/w/index.php?title=Category:%E6%97%A5%E6%9C%AC%E3%81%AE%E7%94%B7%E6%80%A7%E5%A3%B0%E5%84%AA"
  
  # 女性声優のみ  
  # url = "/w/index.php?title=Category:%E6%97%A5%E6%9C%AC%E3%81%AE%E5%A5%B3%E6%80%A7%E5%A3%B0%E5%84%AA"
  d.get_list(url)
  seiyus = d.seiyus.filtering_2ch
  seiyus.each{|name| puts name}
end
