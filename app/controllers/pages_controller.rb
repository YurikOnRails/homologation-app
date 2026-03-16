class PagesController < ApplicationController
  allow_unauthenticated_access

  def privacy_policy
    render inertia: "PrivacyPolicy"
  end
end
