# Copyright 2026, Battelle Energy Alliance, LLC, ALL RIGHTS RESERVED
# Add Custom OOD routes
ActiveSupport.on_load(:after_initialize) do
  # Admin Portal routes
  Rails.logger.info "Checking to add routes..."
  if CurrentUser.group_names.include?(ENV['OOD_ADMIN_GROUP'])
    Rails.logger.info "Admin group found. Adding admin routes."
    Rails.application.routes.append do
      get "/admin", to: "admin#index"
      post "/admin/update_impersonation", to: "admin#update_impersonation"
    end
    Rails.application.reload_routes!
  else
    Rails.logger.info "Admin group not found, /admin route not added"
  end
  Rails.application.reload_routes!
end
