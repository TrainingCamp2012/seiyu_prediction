# -*- coding: utf-8 -*-
class Graph
  def initialize(directed = true)
    @vertexes = [ ]
    @neighbors = Hash.new{|h, k|h[k] = Array.new}
    @weights = Hash.new{0.0}
    
    @directed = directed || false
  end
  
  def read_file(file)
    open(file, "r"){|f|
      f.each do |l|
        # file format
        # from \t to \t weight
        v_1, v_2, w = l.chomp.split(",")
        @vertexes.push v_1
        @vertexes.push v_2
        @neighbors[v_1].push v_2
        @weights[v_1 => v_2] += w.to_f
        
        @neighbors[v_2].push v_1 if !@directed
      end
    }
    @vertexes.uniq!
  end

  def weight(v_1, v_2)
    @directed ? @weights[v_1 => v_2] : [@weights[v_1 => v_2], @weights[v_2 => v_1] ].max
  end
end
