# frozen_string_literal: true

module PgComposite
  module CommandRecorder
    def create_type(*args, &block)
      record(:create_type, args, &block)
    end

    def drop_type(*args, &block)
      record(:drop_type, args, &block)
    end

    def invert_create_type(args, &block)
      [:drop_type, args, block]
    end

    def invert_drop_type(args, &block)
      raise ActiveRecord::IrreversibleMigration, "To avoid mistakes, drop_type is only reversible if given options or a block (can be empty)." if block.nil?

      [:create_type, args, block]
    end
  end
end
