module Users
  class SessionsController < Devise::SessionsController
    # Codespaces can submit from localhost while the app runs on a forwarded HTTPS host.
    # Keep this relaxed in development to avoid CSRF origin false positives.
    skip_before_action :verify_authenticity_token, only: :create, if: -> { Rails.env.development? }
  end
end
