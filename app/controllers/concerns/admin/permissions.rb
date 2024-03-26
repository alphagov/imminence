require "active_support/concern"

module Admin
  module Permissions
    extend ActiveSupport::Concern

    included do
      include GDS::SSO::ControllerMethods

      before_action :authenticate_user!
      helper_method :gds_editor?
      helper_method :org_name_for_current_user
    end

    def gds_editor?
      current_user.permissions.include?("GDS Editor")
    end

    def service_owner?(service)
      service.organisation_slugs.include?(current_user.organisation_slug)
    end

    def permission_for_service?(service)
      gds_editor? || service_owner?(service)
    end

    def org_name_for_current_user
      GdsApi.organisations.organisation(current_user.organisation_slug).to_hash["title"]
    rescue GdsApi::HTTPUnavailable
      current_user.organisation_slug
    end
  end
end
