require "./graph.rb"

class Graph
  def pagerank(damping = 0.85, iteration = 30)
    # Init
    @pagerank_score = Hash.new{1.0}
    transit_prob = Hash.new{0.0}

    # Set transit prob
    @neighbors.each_pair do |v_from, adjs|
      sum = adjs.inject(0.0){|s, v_to| s += weight(v_from, v_to)}
      adjs.each do |v_to|
        transit_prob[v_from => v_to] = weight(v_from, v_to) / sum
      end
    end

    iteration.times do
      tmp_score = Hash.new{0.0}
      @vertexes.each do |v_from|
        @neighbors[v_from].each do |v_to|
          tmp_score[v_to] += transit_prob[v_from => v_to] * @pagerank_score[v_from]
        end
      end
      
      #Update pagerank_score(sum)
      @vertexes.each do |v|
        @pagerank_score[v] = (1 - damping) + damping * tmp_score[v];
      end
    end
    
    @pagerank_score
  end
end


if __FILE__ == $0
  g = Graph.new(false)
  g.read_file(ARGV[0])
  p g.pagerank
end
