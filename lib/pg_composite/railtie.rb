# frozen_string_literal: true

require "rails/railtie"

module PgComposite
  # Automatically initializes PgComposite in the context of a Rails application when
  # ActiveRecord is loaded.
  #
  # @see PgComposite.load
  class Railtie < Rails::Railtie
    initializer "pgcomposite.load" do
      ActiveSupport.on_load :active_record do
        PgComposite.load
      end
    end
  end
end
