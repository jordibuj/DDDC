# frozen_string_literal: true

require_dependency "decidim/petitions/application_controller"

module Decidim
  module Petitions
    class CredentialsController < ApplicationController
      helper Decidim::ApplicationHelper
      include FormFactory
      def index
        @form = form(CredentialForm).instance
        render layout: "layouts/decidim/credentials/credential"
      end

      def create
        @form = form(CredentialForm).from_params(params)
        CreateCredential.call(@form) do
          on(:ok) do |result|
            flash[:notice] = I18n.t("credentials.created", scope: "decidim.petitions")
            redirect_url = URI.parse(@form.linked_uri)
            query = URI.decode_www_form(redirect_url.query || '') << ["credential", result["credential"]]
            redirect_url.query = URI.encode_www_form(query)
            redirect_to redirect_url.to_s
          end

          on(:invalid) do
            flash[:alert] = I18n.t("credentials.invalid", scope: "decidim.petitions")
            render action: "index", layout: "layouts/decidim/credentials/credential"
          end

          on(:error) do
            flash[:alert] = I18n.t("credentials.error", scope: "decidim.petitions")
            render action: "index", layout: "layouts/decidim/credentials/credential"
          end
        end
      end

      private

      def credential_params
        params.require(:credential).permit(:dni)
      end
    end
  end
end
