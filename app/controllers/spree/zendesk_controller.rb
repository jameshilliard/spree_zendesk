# Using JWT from Ruby is straight forward. The below example expects you to have `jwt`
# in your Gemfile, you can read more about that gem at https://github.com/progrium/ruby-jwt.
# Assuming that you've set your shared secret and Zendesk subdomain in the environment, you
# can use Zendesk SSO from your controller like this example.
require 'securerandom' unless defined?(SecureRandom)

class SupportController < ApplicationController
  # Configuration
  ZENDESK_SHARED_SECRET = Spree::Zendesk.secret
  ZENDESK_SUBDOMAIN     = Spree::Zendesk.subdomain
  if defined?(Spree::Zendesk.domain)
    ZENDESK_DOMAIN      = Spree::Zendesk.domain
  else
    ZENDESK_DOMAIN      = "zendesk.com"
  end
  
  #before_action spree_current_user.user_authentications if spree_current_user

  def login
    if defined?(current_spree_user.email)
      sign_into_zendesk(current_spree_user.email)
    else
      redirect_to "https://#{ZENDESK_SUBDOMAIN}.#{ZENDESK_DOMAIN}/"
    end
  end

  private

  def sign_into_zendesk(user)
    # This is the meat of the business, set up the parameters you wish
    # to forward to Zendesk. All parameters are documented in this page.
    iat = Time.now.to_i
    jti = "#{iat}/#{SecureRandom.hex(18)}"

    payload = JWT.encode({
      :iat   => iat, # Seconds since epoch, determine when this token is stale
      :jti   => jti, # Unique token id, helps prevent replay attacks
      :name  => user,
      :email => user,
    }, ZENDESK_SHARED_SECRET)

    redirect_to zendesk_sso_url(payload)
  end

  def zendesk_sso_url(payload)
    url = "https://#{ZENDESK_SUBDOMAIN}.#{ZENDESK_DOMAIN}/access/jwt?jwt=#{payload}"
    url += "&return_to=#{URI.escape(params["return_to"])}" if params["return_to"].present?
    url
  end
end

