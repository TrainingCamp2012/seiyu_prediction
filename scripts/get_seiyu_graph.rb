# -*- coding: utf-8 -*-
require "mysql"
require "yaml"
require "kconv"
require "logger"

# modify query
# ex. \s => _
# Upcase head alphabet
class String
  def query
    ret = self.gsub(/['"]/) {|ch| ch + ch }
    ret.gsub!(/\s/, "_")
    ret[0] = ret[0].upcase if ret =~ /^[a-z]/
    ret
  end
end

config = YAML.load_file("./config.yaml")
names = open("../data/seiyu_namelist_all.txt", "r").read.split("\n")
log = Logger.new("../data/result_#{Time.now.strftime("%Y_%m_%d_%H_%M")}.log")

db = Mysql.init()
db.options(Mysql::SET_CHARSET_NAME, 'utf8')
db.real_connect("localhost", config["mysql_user"], config["mysql_pass"], "jawiki")

seiyu_id = Hash.new{ }

# get seiyu_id
log.info("Get seiyu ids.")
names.each do |name|
  db.query("SELECT * FROM page where page_title = '#{name}' and page_namespace = 0").each do |elem|
    seiyu_id[name] = elem.first.to_i
  end
end

seiyu_index = Hash.new{|h, k| h[k] = Array.new}
title_candidate = Array.new

# 声優側からタイトル一覧を取得
seiyu_id.each_pair do |name, id|
  db.query("SELECT * FROM pagelinks where pl_from = '#{id}' and pl_namespace = 0").each do |elem|
    title = elem.last.toutf8
    seiyu_index[name].push title
    title_candidate.push title
  end
end

title_candidate.uniq!

log.info("title_candidate.size: #{title_candidate.size}")

# リンク要素がアニメかどうかの判定
# これには二種類ある
# 1. そのもののportalを見る
# pl_namespce = 100 にアニメへのリンクを持つか
# 2. リダイレクトを辿る
# ある声優 A からのリンクが X であり， X は Y にリダイレクトしており， Y は Z へのリンクを持つ
# A ---> X ---> Y <---> Z <---> (a, b, c)
# この場合のリダイレクトは X からは Y のみにリンクを張っていることを指す
# Y, Z 共通のportalを持つとする (pl_namespace = 100 にアニメ)
# 具体的には Xがひだまりスケッチ×☆☆☆，Yがひだまりスケッチ_(アニメ)，Zがひだまりスケッチ
# ひだまりスケッチはportalとしてアニメを持つ

# また， pl_namespace = 14 に YYYY年のアニメ といった項目を持っている
# 2000年以降に絞るなら使えるが複数存在する(2008, 2010)

animation_title = [ ]
animation_ids = Hash.new
counter = 0.0
animation_desc = Hash.new{ }
animation_parent = Hash.new{ }
inv_anime_index = Hash.new{|h, k|h[k] = Array.new}

title_candidate.sort.each do |x_title|
  counter += 1
  log.info("Now: #{counter / title_candidate.size * 100}%")
  
  x_id = nil
  db.query("SELECT * FROM page where page_title = '#{x_title.query}' and page_namespace = 0").each do |elem|
    x_id = elem.first.to_i
  end

  next if x_id.nil?

  x_adj_category = [ ]
  #   db.query("SELECT * FROM pagelinks where pl_from = '#{x_id}' and pl_namespace = 14").each do |elem|
  db.query("SELECT * FROM pagelinks where pl_from = '#{x_id}' and pl_namespace = 100").each do |elem|  
    x_adj_category.push elem.last.toutf8
  end

  #   if x_adj_category.to_s =~ /20\d+{2}年のテレビアニメ/
  if x_adj_category.include?("アニメ")
    animation_title.push x_title
    animation_ids[x_title] = x_id

    animation_desc[x_title] = x_adj_category.join(",")
    log.info("#{x_title} is anime. #{x_adj_category.join(",")}")
  else
    x_adj_page = [ ]
    db.query("SELECT * FROM pagelinks where pl_from = '#{x_id}' and pl_namespace = 0").each do |elem|
      x_adj_page.push elem.last.toutf8
    end
    
    if x_adj_page.size == 1
      y_title = x_adj_page.first
      y_id = nil
      
      db.query("SELECT * FROM page where page_title = '#{y_title.query}'").each do |elem|
        y_id = elem.first.to_i
      end
      
      next if y_id.nil?

      log.info("#{x_title} was redirected to #{y_title}")
      
      # リダイレクト先では制約を緩める
      # 100 にアニメを含むものにする
      y_adj_category = [ ]
      # db.query("SELECT * FROM pagelinks where pl_from = '#{y_id}' and pl_namespace = 14").each do |elem|
      db.query("SELECT * FROM pagelinks where pl_from = '#{y_id}' and pl_namespace = 100").each do |elem|
        y_adj_category.push elem.last.toutf8
      end
      # if y_adj_category.to_s =~ /20\d+{2}年のテレビアニメ/
      if y_adj_category.include?("アニメ")
        animation_parent[x_title]  = y_title
        animation_title.push x_title
        animation_ids[x_title] = x_id

        animation_desc[x_title] = y_adj_category.join(",")
        log.info("#{x_title} is anime(from #{y_title}). #{y_adj_category.join(",")}")
      end
    end
  end
end

animation_title.uniq!

# アニメ側から再度辿る
from_anime = Hash.new{|h, k|h[k] = Array.new}
animation_ids.each_pair do |title, anime_id|
  db.query("SELECT * FROM pagelinks where pl_from = '#{anime_id}' and pl_namespace = 0").each do |elem|
    name = elem.last.toutf8
    from_anime[title].push name if !seiyu_id[name].nil?
  end
end

seiyu_index.each_pair do |seiyu, animes|
  (animes & animation_title).each do |title|
    inv_anime_index[title].push seiyu
  end
end

inv_anime_index.each_key do |key|
  inv_anime_index[key].uniq!
end

open("../data/seiyu_ids_all.txt", "w"){|f|
  seiyu_id.each_pair do |k, v|
    f.puts "#{k},#{v}"
  end
}

open("../data/animation_ids.txt", "w"){|f|
  animation_ids.each_pair do |k, v|
    f.puts "#{k},#{v}"
  end
}

open("../data/seiyu_graph_all.txt", "w"){|f|
  inv_anime_index.each_pair do |anime, seiyus|
    f.puts anime + "\t" + seiyus.join(",")
  end
}

open("../data/animation_desc.txt", "w"){|f|
  animation_desc.each_pair do |anime, desc|
    f.puts anime + "\t" + desc
  end
}

open("../data/animation_parent.txt", "w"){|f|
  animation_parent.each_pair do |anime, parent|
    f.puts anime + "," + parent
  end
}

open("../data/animation_from_anime.txt", "w"){|f|
  from_anime.each_pair do |anime, arys|
    f.puts anime + "," + arys.join(",")
  end
}


