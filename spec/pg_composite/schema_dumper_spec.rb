# frozen_string_literal: true

require "spec_helper"

RSpec.describe PgComposite::SchemaDumper do
  it "dumps a create_type for a type in the database" do
    ActiveRecord::Base.connection.create_type :complex do |t|
      t.float :r
      t.float :i
    end

    stream = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    output = stream.string

    expect(output).to include(
      <<-RUBY
  create_type "complex" do |t|
    t.float "r"
    t.float "i"
  end
      RUBY
    )
  ensure
    begin
      connection.drop_type :complex
    rescue PG::UndefinedObject
    end
  end

  def connection
    ActiveRecord::Base.connection
  end
end
