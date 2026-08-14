class ApplicationController < ActionController::API
  # ActionController::API doesn't include this by default, but Devise's
  # internal controllers (e.g. the sign-out action) use `respond_to` blocks.
  include ActionController::MimeResponds
end
