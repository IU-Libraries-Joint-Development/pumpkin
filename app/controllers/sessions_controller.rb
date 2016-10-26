class SessionsController < Devise::SessionsController

  # GET /resource/global_sign_out
  # Destroy the local session and then request CAS to invalidate the TGT.
  def global_logout
    signed_out = (Devise.sign_out_all_scopes ? sign_out
      : sign_out(resource_name)) # Copied from devise/sessions_controller.rb

    options = Devise.omniauth_configs[:cas].options
    host = options[:host] || 'localhost'
    path = options[:logout_url] || '/logout'
    redirect_to "https://#{host}#{path}"
  end

end
