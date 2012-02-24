# -*- coding: utf-8 -*-
# Classification in Graphs using Discriminative Random Walks
# url: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.139.6489
# description: http://d.hatena.ne.jp/repose/20110517/1305636836
class DWalks
  def initialize
    @edges = Hash.new{|h, k|h[k] = Hash.new{ }}
    @labels = { }
    @nodes = [ ]
    @labels_index = Hash.new{|h, k|h[k] = Array.new}
    @prob = Hash.new{0.0}
    @alpha = { }
    @beta = { }
  end

  # フォーマット
  # node1, node2, weight
  # ex. 1,2,100
  def read_graph(file_name)
    open(file_name){|f|
      f.each{|l|
        ary = l.chomp.split(",")
        if ary.size == 3        
          from, to, weight = ary
        else
          from, to = ary
          weight = 1
        end
        
        @edges[from][to] = weight.to_i
        @nodes.push from
        @nodes.push to
      }
    }
    calc_prob
    @nodes.uniq!
  end

  # フォーマット
  # node, label
  # ex. 1,3
  def read_label(file_name)
    open(file_name){|f|
      f.each{|l|
        node, label = l.chomp.split(",")
        @labels[node] = label
        @labels_index[label].push node
      }
    }
  end

  # 遷移確率のテーブルを一括計算
  def calc_prob
    @edges.each_pair do |from, adj|
      sum = adj.values.inject(0.0){|s, e|s += e}
      adj.each_pair do |to, weight|
        @prob[from => to] = weight / sum
      end
    end
  end

  # アルファとベータは再帰しつつ保存しておく
  def alpha(y, q, t)
    if @alpha[[y ,q, t]].nil?
      if t == 1
        @alpha[[y, q, 1]] = @labels_index[y].inject(0.0){|s, e| s += @prob[e => q]} / @labels_index[y].size
      else
        @alpha[[y, q, t]] = (@nodes - @labels_index[y]).inject(0.0){|s, e| s+= alpha(y, e, t - 1) * @prob[e => q]}
      end
    end
    @alpha[[y ,q, t]]
  end

  def beta(y, q, t)
    if @beta[[y, q, t]].nil?
      if t == 1
        @beta[[y, q, 1]] = @labels_index[y].inject(0.0){|s, e| s += @prob[q=> e]}
      else
        @beta[[y, q, t]] = (@nodes - @labels_index[y]).inject(0.0){|s, e| s+= beta(y, e, t - 1) * @prob[q => e]}
      end
    end
    @beta[[y, q, t]]
  end

  # ラベル推定
  def estimation(q, length)
    b = Hash.new

    # ラベルが既にあったら終了
    if !@labels[q].nil?
      puts "query: #{q} is #{@labels[q]}!"
      exit(1)
    end

    # ノードがそもそもグラフになかったら終了
    if !@nodes.include?(q)
      puts "query: #{q} not found in graph!"
      exit(1)
    end

    @labels_index.each_pair do |label, nodes|
      demo = 0.0; nume = 0.0
      1.upto(length) do |l|
        demo += nodes.inject(0.0){|s, e| s += alpha(label, e, l)}
        1.upto(l - 1) do |t|
          nume += alpha(label, q, t) * beta(label, q, l - t)
        end
      end
      b[label] = nume / demo
    end
    b.to_a.sort{|x, y| y[1] <=> x[1]}[0]
  end
end

if __FILE__ == $0
  # ruby label_classification.rb graph.txt label.txt test.txt length
  d = DWalks.new
  d.read_graph(ARGV[0])
  d.read_label(ARGV[1])
  length = ARGV[3].to_i
  open(ARGV[2], "r"){|f|
    f.each do |l|
      node = l.chomp
      puts "#{node},#{d.estimation(node, length)}"
    end
  }
end
