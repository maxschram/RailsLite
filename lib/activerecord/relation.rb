module Searchable
  def where(params)
    Relation.new(self, params)
  end
end

class Relation
  extend Enumerable

  def initialize(class_name, params = {})
    @params = params
    @class_of_relation = class_name
    @cached_data = {}
    @items = nil
    @included_assocs = []
  end

  def each(&blk)
    load unless @items
    i = 0

    while i < items.length
      yield(items[i])
      i += 1
    end
  end

  def cache_assoc(association)
    @included_assocs << @class_of_relation.class_variable_get(:assoc)
  end

  def where(new_params)
    params.merge(new_params)
    self
  end

  def first
    load unless @items
    @items.first
  end

  def inspect
    @items || load
  end

  def load
    return load_all if params.empty?
    return load_includes unless @included_assocs.empty?

    where_line = params.keys.map do |key|
      "#{key} = '#{params[key]}'"
    end.join(" AND ")

    data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{class_of_relation.table_name}
      WHERE #{where_line}
    SQL

    @items = data.map { |datum| class_of_relation.new(datum) }
  end

  def load_includes
    where_line = params.keys.map do |key|
      "#{key} = '#{params[key]}'"
    end.join(" AND ")
    assoc = included_assocs.first

    if assoc.is_a?(BelongsToOptions)
      join_line = "#{class_name.to_s.tableize}.#{assoc.primary_key} = #{assoc.class_name.to_s.tableize}.#{assoc.foreign_key}"
    elsif assoc.is_a?(HasManyOptions)
      join_line = "#{class_name.to_s.tableize}.#{assoc.foriegn_key} = #{assoc.class_name.to_s.tableize}.#{assoc.primary_key}"
    else
      raise "Unknown association"
    end

    select_line = "#{class_name.to_s.tableize}.*, #{assoc.class_name.to_s.tableize}.*"
    from_line = class_of_relation.table_name
    data = DBConnection.execute(<<-SQL)
      SELECT #{select_line}
      FROM #{from_line}
      JOIN #{join_line}
      WHERE #{where_line}
    SQL

    @items = data.map do |datum|
      new_obj = class_of_relation.new(datum.slice(:id, :fname, :lname, :house_id))
      new_obj.define_singleton_method(:test) do
        # assoc.class_name.new(datum.slice(:id, :name, :owner_id))
        puts "test"
      end
    end
  end

  def load_all
    data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{class_of_relation.table_name}
    SQL
    @items = data.map { |datum| class_of_relation.new(datum) }
  end

  private

  attr_reader :params, :class_of_relation, :cached_data, :included_assocs
  attr_accessor :items
end
