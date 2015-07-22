class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id
  finalize!
end
