# -*- coding: utf-8 -*-
# filename: link_prediction.rb

require "./graph.rb"

class Graph
  attr_reader :neighbors
  def prediction(v_s, length)
    found = [ ]; found.push v_s
    new_search = [ ]; new_search.push v_s
    large_s = Hash.new{0.0}; large_s[v_s] = 1
    
    0.upto(length) do |current_degree|
      old_search = Marshal.load(Marshal.dump(new_search))
      new_search.clear
      while !old_search.empty?
        v_i = old_search.pop
        # ここが合ってるか不明
        w_v_s = large_s[v_s]
        sum_output = 0.0
        
        @neighbors[v_i].each do |v_j|
          sum_output += weight(v_i, v_j)
        end
        
        flow = 0.0
        
        @neighbors[v_i].each do |v_j|
          flow = w_v_s * weight(v_i, v_j) / sum_output
          large_s[v_j] += flow
          if !found.include?(v_j)
            found.push v_j
            new_search.push v_j
          end
        end
      end
    end
    
    # Filtering
    large_s.delete(v_s)
    @neighbors[v_s].each do |v_i|
      large_s.delete(v_i)
    end
    large_s
  end
end



if __FILE__ == $0
  file = ARGV[0]
  start_node = ARGV[1]
  depth  =ARGV[2].to_i
  
  g = Graph.new(false)
  g.read_file(file)
  scores = g.prediction(start_node, depth)
  # 既存のノードはフィルタリング
  p scores.select{|node, v| !g.neighbors[start_node].include?(node)}.to_a.sort{|a, b|b[1] <=> a[1]}
end
