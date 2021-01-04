class CocietyRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :cociety, reading: :cociety }
end
