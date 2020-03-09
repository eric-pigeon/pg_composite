# frozen_string_literal: true

require "pg_composite/command_recorder"
require "pg_composite/railtie"
require "pg_composite/schema_dumper"
require "pg_composite/statements"
require "pg_composite/version"

module PgComposite
  # Hooks PgComposite into Rails.
  #
  # Enables pgcomposite migration methods, migration reversability, and `schema.rb`
  # dumping.
  #
  def self.load
    ActiveRecord::ConnectionAdapters::AbstractAdapter.include PgComposite::Statements
    ActiveRecord::Migration::CommandRecorder.include PgComposite::CommandRecorder
    ActiveRecord::SchemaDumper.prepend PgComposite::SchemaDumper
  end
end
