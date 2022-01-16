require 'logger'
require 'json'
require 'faraday'
require './SecretManager.rb'

APP_KEY = "LINE_WORKS_BOT"

class PaymentChecker
  def initialize
    begin
      ENV['TZ'] = 'Azia/Tokyo'

      @secret = SecretManager.new(APP_KEY)
      @logger = Logger.new($stdout)

      @base_url = @secret.get_secret("BASE_URL")
      @access_token = @secret.get_secret("ACCESS_TOKEN")

      @headers = {"Content-Type": "applicatoin/json", "charset": "UTF-8", "Authorization": "Bearer " + @access_token }
    rescue => e
      @logger.error(e)
    end
  end

  def get_user
    request_url = @base_url +
    res = Faraday.get(@base_url, params = nil)
  end
end
