# frozen_string_literal: true

module PgComposite
  # Methods that are made available in migrations for managing composite types
  #
  module Statements
    def create_type(type_name)
      raise "block required" unless block_given?

      td = create_type_definition(type_name)

      yield td

      execute td.to_sql
    end

    def drop_type(type_name)
      schema_cache.clear_data_source_cache!(type_name.to_s)
      execute "DROP TYPE #{quote_table_name(type_name)}"
    end

    def attribute_definitions(type_name)
      query(<<~SQL, "SCHEMA")
        SELECT a.attname, format_type(a.atttypid, a.atttypmod),
               pg_get_expr(d.adbin, d.adrelid), a.attnotnull, a.atttypid, a.atttypmod,
               c.collname, col_description(a.attrelid, a.attnum) AS comment
          FROM pg_attribute a
          LEFT JOIN pg_attrdef d ON a.attrelid = d.adrelid AND a.attnum = d.adnum
          LEFT JOIN pg_type t ON a.atttypid = t.oid
          LEFT JOIN pg_collation c ON a.attcollation = c.oid AND a.attcollation <> t.typcollation
         WHERE a.attrelid = #{quote(quote_table_name(type_name))}::regclass
           AND a.attnum > 0 AND NOT a.attisdropped
         ORDER BY a.attnum
      SQL
    end

    def types
      query_values <<~SQL
        SELECT c.relname
        FROM pg_class c
        LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relkind = 'c'
        AND c.relname NOT IN ('tablefunc_crosstab_2', 'tablefunc_crosstab_3', 'tablefunc_crosstab_4')
      SQL
    end

    private

      def create_type_definition(name)
        TypeDefinition.new(self, name)
      end

      class TypeDefinition
        def self.define_column_methods(*column_types) # :nodoc:
          column_types.each do |column_type|
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{column_type}(*names, **options)
                raise ArgumentError, "Missing column name(s) for #{column_type}" if names.empty?
                names.each { |name| column(name, :#{column_type}, **options) }
              end
            RUBY
          end
        end
        private_class_method :define_column_methods

        define_column_methods :bigint, :binary, :boolean, :date, :datetime, :decimal,
                              :float, :integer, :json, :string, :text, :time, :timestamp, :virtual

        delegate :quote_column_name, :quote_table_name, :type_to_sql, to: :@conn, private: true

        attr_reader :name

        def initialize(conn, name)
          @conn = conn
          @name = name
          @columns_hash = {}
        end

        def to_sql
          create_sql = String.new "DROP TYPE IF EXISTS #{quote_table_name(name)};"
          create_sql << "CREATE TYPE #{quote_table_name(name)} AS ("
          statements = columns.map do |c|
            c.sql_type = type_to_sql(c.type)
            "#{quote_column_name(c.name)} #{c.sql_type}"
          end
          create_sql << statements.join(", ")
          create_sql << ")"
        end

        # Returns an array of ColumnDefinition objects for the columns of the table.
        def columns
          @columns_hash.values
        end

        private

          def column(name, type)
            name = name.to_s
            type = type.to_sym if type

            raise ArgumentError, "you can't define an already defined column '#{name}'." if @columns_hash[name]

            @columns_hash[name] = new_column_definition(name, type)
            self
          end

          def new_column_definition(name, type)
            type = aliased_types(type.to_s, type)
            create_column_definition(name, type)
          end

          def aliased_types(name, fallback)
            name == "timestamp" ? :datetime : fallback
          end

          def create_column_definition(name, type)
            ActiveRecord::ConnectionAdapters::ColumnDefinition.new(name, type)
          end
      end
  end
end
