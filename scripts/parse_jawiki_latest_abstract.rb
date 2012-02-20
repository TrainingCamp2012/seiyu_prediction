# -*- coding: utf-8 -*-
require "nokogiri"

data_path = File.dirname(File.expand_path(__FILE__)) + "/../data/"
xml_path = current + "jawiki-latest-abstract.xml"
output_path = current + "output.txt"

xml = Nokogiri::XML(open(xml_path))

open(output_path, "w"){|f|
  (xml/"doc").each do |doc|
    f.puts (doc/"title").inner_text if (doc/"abstract").inner_text.include?("声優")
  end
}
