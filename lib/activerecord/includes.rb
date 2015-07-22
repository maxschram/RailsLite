require_relative 'db_connection'
require_relative '01_sql_object'
require_relative '03_associatable'
require_relative 'relation'

module Includeable
  def includes(association)
    r = Relation.new(self)
    r.cache_assoc(association)
    r
  end
end

class SQLObject
  extend Includeable
end

class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id

  finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  has_many :cats, foreign_key: :owner_id
  belongs_to :house

  finalize!
end

class House < SQLObject
  has_many :humans

  finalize!
end


humans = Human.includes(:cat)
humans.each do |human|
  human.cat.name
end
