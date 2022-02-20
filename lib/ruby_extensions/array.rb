class Array
  def longest_continuous_range_by
    return nil if empty?

    return [0..0] if one?
    
    range_start = 0
    range_end = 0
    longest = 1
    current_block_condition = nil
    current_length = 0

    each_with_index do |current, i|
      changed = yield(current) != current_block_condition
      if changed
        longer = current_length > (range_end - range_start)
        if longer
          range_end = i-1
          range_start = range_end - current_length
        end
        current_block_condition = yield(current)
        current_length = 1
      else
        current_length += 1
      end

      last_one = (i+1) == size
      if last_one
        longer = current_length > (range_end - range_start)
        if longer
          range_end = i
          range_start = range_end - current_length + 1
        end
      end
    end

    range = (range_start..range_end)
    self.[](range)
  end
end