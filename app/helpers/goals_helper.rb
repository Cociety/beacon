
module GoalsHelper
  def parallelizable?(goal)
    @goals_to_parallelize&.include? goal
  end
end
