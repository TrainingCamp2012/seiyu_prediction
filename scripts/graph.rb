# -*- coding: utf-8 -*-
class Graph
  def initialize(directed = true)
    @vertexes = [ ]
    @neighbors = Hash.new{|h, k|h[k] = Array.new}
    @weights = Hash.new{0.0}

    @directed = directed
  end

  def read_file(file)
    open(file, "r"){|f|
      f.each do |l|
        # File format
        # from \t to \t weight
        v_1, v_2, w = l.chomp.split(",")
        edge(v_1, v_2, w.to_f)
      end
    }
    @vertexes.uniq!
  end

  def edge(v_from, v_to, w)
    @vertexes.push v_from
    @vertexes.push v_to
    @neighbors[v_from].push v_to
    @weights[v_from => v_to] += w

    unless @directed
      @neighbors[v_to].push v_from
      @weights[v_to => v_from] += w
    end
  end

  def weight(v_from, v_to)
    @directed ? @weights[v_from => v_to] : [@weights[v_from => v_to], @weights[v_to => v_from]].max
  end
end
