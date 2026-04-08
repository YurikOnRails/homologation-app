ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"
require "inertia_rails/testing"

InertiaRails::Testing.install!

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    include FactoryBot::Syntax::Methods

    setup do
      %w[super_admin coordinator teacher student].each do |name|
        Role.find_or_create_by!(name: name)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include InertiaRails::Testing::Helpers
end
