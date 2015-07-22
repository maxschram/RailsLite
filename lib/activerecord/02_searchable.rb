require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map do |key|
      "#{key} = '#{params[key]}'"
    end.join(" AND ")

    data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
      WHERE #{where_line}
    SQL

    return [] if data.empty?
    data.map { |datum| self.new(datum) }
  end
end

class SQLObject
  extend Searchable
end
