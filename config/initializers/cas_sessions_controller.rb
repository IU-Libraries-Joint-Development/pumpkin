# Special session management for CAS
#
# Copyright:: Copyright 2016 Indiana University

require 'devise/sessions_controller.rb'

Devise::SessionsController.class_eval do
  # Quiet, RuboCop!

  # GET /resource/global_sign_out
  # Destroy the local session and then request CAS to invalidate the TGT.
  def global_logout
    # Adapted from #destroy
    if Devise.sign_out_all_scopes
    then sign_out
    else sign_out(resource_name)
    end

    # Now sign out of CAS
    options = Devise.omniauth_configs[:cas].options
    host = options[:host] || 'localhost'
    path = options[:logout_url] || '/logout'
    redirect_to "https://#{host}#{path}"
  end
end
