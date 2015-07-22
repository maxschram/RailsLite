module Includeable
  def includes(association)
    r = Relation.new(self)
    r.cache_assoc(association)
    r
  end
end
