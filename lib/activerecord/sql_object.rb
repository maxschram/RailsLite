require_relative 'db_connection'
# require_relative 'searchable'
require_relative 'associatable'
require_relative 'includes'
require_relative 'relation'
require 'active_support/inflector'

class SQLObject

  extend Associatable, Searchable, Includeable
  def self.columns
    col_strings = DBConnection.execute2("SELECT * FROM #{table_name}").first
    col_strings.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT #{table_name}.*
      FROM #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |data|
      self.new(data)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT #{table_name}.*
      FROM #{table_name}
      WHERE id = ?
    SQL

    return nil if data.empty?
    self.new(data.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name_sym = attr_name.to_sym
      unless self.class.columns.include?(attr_name_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |column| send(column) }
  end

  def insert
    col_names = self.class.columns.join(', ')
    question_marks = (["?"] * self.class.columns.length).join(', ')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_columns_attrs = self.class.columns.map do |attr_name|
      "#{attr_name} = '#{send(attr_name)}'"
    end

    DBConnection.execute(<<-SQL, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_columns_attrs.join(', ')}
      WHERE
        id = ?
    SQL
  end

  def destroy
    DBConnection.execute(<<-SQL, id)
      DELETE FROM #{self.class.table_name}
      WHERE id = ?
    SQL
  end

  def persisted?
    !id.nil?
  end

  def save
    id.nil? ? insert : update
  end
end
