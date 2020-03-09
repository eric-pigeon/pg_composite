# frozen_string_literal: true

require "spec_helper"

RSpec.describe PgComposite::SchemaDumper, :db do
  describe "create_type" do
    it "records creating a type" do
      proc = proc do |t|
        t.float :r
        t.float :i
      end
      recorder.create_type :complex, &proc

      expect(recorder.commands).to eq [[:create_type, [:complex], proc]]
    end

    it "reverts to drop_type" do
      proc = proc do |t|
        t.float :r
        t.float :i
      end
      recorder.revert { recorder.create_type :complex, &proc }

      expect(recorder.commands).to eq [[:drop_type, [:complex], proc]]
    end
  end

  describe "drop_type" do
    it "records droping a type" do
      proc = proc do |t|
        t.float :r
        t.float :i
      end
      recorder.drop_type :complex, &proc

      expect(recorder.commands).to eq [[:drop_type, [:complex], proc]]
    end

    it "reverts to create_type" do
      proc = proc do |t|
        t.float :r
        t.float :i
      end
      recorder.revert { recorder.drop_type :complex, &proc }

      expect(recorder.commands).to eq [[:create_type, [:complex], proc]]
    end

    it "raises when inverted unless a block is provided" do
      expect { recorder.revert { recorder.drop_type :complex } }
        .to raise_error ActiveRecord::IrreversibleMigration
    end
  end

  def recorder
    @recorder ||= ActiveRecord::Migration::CommandRecorder.new
  end
end
