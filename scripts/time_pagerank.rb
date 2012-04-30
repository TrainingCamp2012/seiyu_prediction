# -*- coding: utf-8 -*-
require './pagerank.rb'

class TimePageRank
  def initialize(lim = 200701)
    @data = Hash.new{ |h, k|h[k] = Array.new}
    @scores = Hash.new{ |h, k|h[k] = Array.new}
    @files = [ ]
    # これよりあとのアニメしか考慮しない
    @lim = lim
  end

  # format
  # title \t year-month \t seiyu \t seiyu \t seiyu ...
  def read_original_file(file)
    open(File.expand_path(file), 'r'){ |f|
      f.each do |l|
        ary = l.chomp.split("\t")
        year = ary[1].split("-").join("").to_i
        next if year < @lim
        @data[year].push ary[2..-1]
      end
    }

    @files.push File.basename(file)
    @save_path = File.dirname(File.expand_path(file))
  end

  def construct_graph(lim_year)
    g = Graph.new(false)
    @data.each_pair do |year, animes|
      next if lim_year < year
      animes.each do |seiyus|
        seiyus.combination(2).each do |e|
          g.edge(e.first, e.last, 1)
        end
      end
    end
    g
  end

  def calc
    years = @data.keys.sort
    years.each_with_index do |year, i|
      puts "Now #{year} (#{i + 1}/#{years.size})"
      construct_graph(year).pagerank.each_pair do |seiyu, value|
        @scores[seiyu].push [year, value]
      end
    end
    @scores
  end

  # pagerank の first と last の差分が大きいもの順にソート
  def sorted_score
    @scores.to_a.sort do |b, a|
      (a.last.last.last - a.last.first.last) <=> (b.last.last.last - b.last.first.last)
    end
  end

  def write
    open("#{@save_path}/result_#{@files.join("_")}_#{@lim}.tsv", "w"){ |f|
      sorted_score.each do |e|
        seiyu = e.first
        values = e.last
        values.each do |v|
          f.puts "#{seiyu},#{v.join(",")}"
        end
      end
    }
  end
end


# Usage
# ruby time_pagerank.rb 200701 file1.tsv file2.tsv ...
# Output
# file1.tsv のディレクトリ
if __FILE__ == $0
  t = TimePageRank.new(ARGV[0].to_i)
  ARGV[1..-1].each do |f|
    t.read_original_file(f)
  end
  t.calc
  t.write
end
