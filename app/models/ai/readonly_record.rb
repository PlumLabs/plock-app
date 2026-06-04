module Ai
  class ReadonlyRecord < ApplicationRecord
    self.abstract_class = true

    connects_to database: { reading: :ai_readonly, writing: :ai_readonly }
  end
end
