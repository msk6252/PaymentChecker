require 'stripe'
require 'logger'
require './SecretManager.rb'

class StripeModule
  def initialize
    begin
      @logger = Logger.new($stdout)
      @client = SecretManager.new("PaymentChecker")
      Stripe.api_key = @client.get_secret("STRIPE_TEST_API_KEY")
    rescue => e
      @logger.error("[Stripe] Initialize: #{e}")
    end
  end

  def get_payments
    begin
      pay_list = Stripe::PaymentIntent.list()
      list = []
      pay_list["data"].each do | payment |
        payment["charges"]["data"].each do | charge |
          list << charge
        end
      end
      return list
    rescue => e
      @logger.error("[Stripe] GET Payments: #{e}")
    end
  end
end
