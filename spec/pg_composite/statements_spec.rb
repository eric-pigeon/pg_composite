# frozen_string_literal: true

require "spec_helper"

module PgComposite
  RSpec.describe Statements do
    describe "create_type" do
      it "creates a composite type" do
        connection.create_type :complex do |t|
          t.float :r
          t.float :i
        end

        expect(attributes(:complex).size).to eq 2
      ensure
        begin
          connection.drop_type :complex
        rescue PG::UndefinedObject
        end
      end
    end

    def connection
      ActiveRecord::Base.connection
    end

    def attributes(type_name)
      connection.send(:attribute_definitions, type_name).map do |name, type, default|
        "#{name} #{type}" + (default ? " default #{default}" : "")
      end
    end
  end
end
