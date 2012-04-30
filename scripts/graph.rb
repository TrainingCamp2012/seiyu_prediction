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
  end

  def edge(v_f, v_t, w)
    v_from = v_f.to_sym
    v_to = v_t.to_sym
    @vertexes.push v_from if !@vertexes.include?(v_from)
    @vertexes.push v_to if !@vertexes.include?(v_to)
    @neighbors[v_from].push v_to if !@neighbors[v_from].include?(v_to)
    @weights[v_from => v_to] += w

    unless @directed
      @neighbors[v_to].push v_from if !@neighbors[v_to].include?(v_from)
      @weights[v_to => v_from] += w
    end
  end

  def weight(v_from, v_to)
    @directed ? @weights[v_from => v_to] : [@weights[v_from => v_to], @weights[v_to => v_from]].max
  end
end
