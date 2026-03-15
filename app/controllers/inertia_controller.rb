# frozen_string_literal: true

# Base controller for all Inertia-rendered pages.
# All page controllers inherit from here to get authentication and authorization.
# Authentication is inherited from ApplicationController.
class InertiaController < ApplicationController
  after_action :verify_authorized
end
