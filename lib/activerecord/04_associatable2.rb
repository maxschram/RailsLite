require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

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
