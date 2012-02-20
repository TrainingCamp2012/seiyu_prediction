# -*- coding: utf-8 -*-
# crawl SEIYU lists from wikipedia
require "nokogiri"
require "open-uri"

# edge_case = "http://ja.wikipedia.org/w/index.php?title=Category:%E6%97%A5%E6%9C%AC%E3%81%AE%E5%A5%B3%E6%80%A7%E5%A3%B0%E5%84%AA&pagefrom=%E3%82%8A%E3%82%85%E3%81%86+%E3%81%9B%E3%81%84%E3%82%89%0A%E5%8A%89%E3%82%BB%E3%82%A4%E3%83%A9#mw-pages"

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

if $0 == __FILE__
  d = Crawler.new
  
  d.get_list("/w/index.php?title=Category:%E6%97%A5%E6%9C%AC%E3%81%AE%E5%A5%B3%E6%80%A7%E5%A3%B0%E5%84%AA")
  open("./list.txt", "w"){|f|
    d.seiyus.each{|name| f.puts name}
  }
end
