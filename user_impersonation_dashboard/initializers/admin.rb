# Copyright 2026, Battelle Energy Alliance, LLC, ALL RIGHTS RESERVED
Rails.application.config.after_initialize do
  require 'ood_core'

  class AdminImpersonation
      include ActiveModel::Model
  
      attr_accessor :impersonation_username, :impersonation_reason
  
      validates :impersonation_username, presence: true
      validates :impersonation_reason, presence: true
  end

  class AdminController < ApplicationController
    def index
      @admin_impersonation = AdminImpersonation.new
    end

    def update_impersonation
        @admin_impersonation = AdminImpersonation.new(admin_impersonation_params)
        if @admin_impersonation.valid?
            auth_map_file = ENV['OOD_DASHBOARD_ADMIN_AUTH_MAP_FILE'] || "/opt/ood/ood_auth_map/bin/ood_auth_map.regex"
            log_file = ENV['OOD_DASHBOARD_ADMIN_AUTH_LOG_FILE'] || "/var/log/ood-impersonation.log"

            impersonation_username = @admin_impersonation.impersonation_username
            impersonation_reason = @admin_impersonation.impersonation_reason
            user = CurrentUser.name
            update_time = Time.now
            log_message = "#{update_time}, #{user}, #{impersonation_username}, #{impersonation_reason}"

            new_impersonated_user = "#{user}_IMPERSONATION=\"#{impersonation_username}\""

            # Update the auth map file with the new user
            begin
                file_content = File.read(auth_map_file)
                updated_content = file_content.gsub(/^#{user}_IMPERSONATION=".*"$/, new_impersonated_user)
                File.open(auth_map_file, 'w') { |file| file.write(updated_content) }
                flash[:success_impersonated_user] = "Impersonated user updated to: #{impersonation_username}"
            rescue => e
                flash[:error] = "Impersonated user update may have failed. Error: #{e.message}"
            end

            # Log the update for user auth
            begin
                File.open(log_file, 'a') do |file|
                    file.puts log_message
                end
                flash[:success_impersonated_logged] = "Successfully logged impersonation attempt"
            rescue => e
                flash[:error] = "Issue logging impersonation attempt. Error: #{e.message}"
            end

        redirect_to admin_path

        else
            # Handle validation errors
            flash.now[:error] = @admin_impersonation.errors.full_messages.join(', ')
            render :index
        end
    end
    private

    def admin_impersonation_params
        params.require(:admin_impersonation).permit(:impersonation_username, :impersonation_reason)
    end
  end
end

