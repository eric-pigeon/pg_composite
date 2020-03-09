# frozen_string_literal: true

module PgComposite
  module SchemaDumper
    private

      def trailer(stream)
        dump_types(stream)
        super
      end

      def dump_types(stream)
        sorted_types = @connection.types.sort

        sorted_types.each do |type_name|
          type(type_name, stream)
        end
      end

      def type(type, stream)
        columns = @connection.columns(type)

        begin
          typ = StringIO.new

          typ.puts
          typ.puts "  create_type #{remove_prefix_and_suffix(type).inspect} do |t|"

          columns.each do |column|
            raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" unless @connection.valid_type?(column.type)

            col_type, colspec = column_spec(column)
            if col_type.is_a?(Symbol)
              typ.print "    t.#{col_type} #{column.name.inspect}"
            else
              typ.print "    t.column #{column.name.inspect}, #{type.inspect}"
            end
            typ.print ", #{format_colspec(colspec)}" if colspec.present?
            typ.puts
          end

          typ.puts "  end"

          typ.rewind
          stream.print typ.read
        rescue StandardError => e
          stream.puts "# Could not dump type #{type.inspect} because of following #{e.class}"
          stream.puts "#   #{e.message}"
          stream.puts
        end
      end
  end
end
