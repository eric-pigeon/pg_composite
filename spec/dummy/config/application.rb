# frozen_string_literal: true

require_relative "boot"

# require 'rails/all'
require "active_record/railtie"

Bundler.require(*Rails.groups)
require "pg_composite"

module Dummy
  class Application < Rails::Application
    config.load_defaults 5.2
    config.cache_classes = true
    config.eager_load = false
    config.active_support.deprecation = :stderr
  end
end
