# -*- coding: utf-8 -*-

# Porpose: Extract seiyu entry's id

require "mysql"
require "yaml"
require "kconv"

config = YAML.load_file("./config.yaml")

seiyu = Hash.new{ }
templates = Array.new
prev_id = nil

templatelinks = Array.new
open("../data/templatelinks.dump", "rb"){|f|
  templatelinks = Marshal.load(f)
}

# db = Mysql.init()
# db.options(Mysql::SET_CHARSET_NAME, 'utf8')
# db.real_connect("localhost", config["mysql_user"], config["mysql_pass"], "jawiki")
# db.query("SELECT * FROM templatelinks").each do |elem|
# end

counter = 0
size = templatelinks.size.to_f

templatelinks.each do |elem|
  counter += 1
#  p counter / size
  id = elem.first
  prev_id ||= id
  if id != prev_id
    # Check whether seiyu or not
    templates_str = templates.join(",")
    # seiyu[prev_id] = templates.dup if templates.first.include?("男性声優") || templates.first.include?("女性声優")
    if templates_str.include?("声優")
      seiyu[prev_id] = templates.dup
      puts templates_str
    end
    
    
    templates.clear
    prev_id = id
  end
  templates.push elem.last.toutf8
end

open("../data/seiyu_ids.txt", "w"){|f|
  seiyu.each_pair{|k, v|f.puts "#{k},#{v.join(",")}"}
}

