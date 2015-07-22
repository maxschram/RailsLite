class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
    :name
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    @foreign_key =
      options[:foreign_key] || "#{name}_id".to_sym
    @class_name =
      options[:class_name] || name.to_s.camelize
    @primary_key =
      options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    @foreign_key =
      options[:foreign_key] || "#{self_class_name.to_s.underscore}_id".to_sym
    @class_name =
      options[:class_name] || name.to_s.singularize.camelcase
    @primary_key =
      options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign_key).first
    end
    @@assoc = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)

    define_method(name) do
      primary_key = send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_key)
    end

    @@assoc = options
  end

  def assoc_options
    @options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      source_table = source_options.table_name

      join_on_line = "#{through_table}.#{source_options.foreign_key} = "+
        "#{source_table}.#{source_options.primary_key}"
      where_line = "#{through_table}.#{through_options.primary_key} = "+
          "#{send(through_options.foreign_key)}"

      data = DBConnection.execute(<<-SQL)
        SELECT #{source_table}.*
        FROM #{through_table}
        JOIN #{source_table} ON #{join_on_line}
        WHERE #{where_line}
      SQL
      source_options.model_class.parse_all(data).first
    end
  end
end
