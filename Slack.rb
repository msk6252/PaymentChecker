require 'logger'
require 'faraday'
require 'json'
require './SecretManager.rb'

class Slack
  BASE_URL = "https://slack.com/api/"
  def initialize
    begin
      @logger = Logger.new($stdout)
      @client = SecretManager.new("PaymentChecker")
    rescue => e
      @logger.error("[Slack] Initialize: #{e}")
    end
  end

  def get_user
    begin
      token = @client.get_secret("SLACK_TOKEN")
      return unless token
      header = {
                 'Content-Type' => 'application/x-www-form-urlencoded',
                 'Authorization' => 'Bearer ' + token
               }
      conn = Faraday.new(url: BASE_URL, headers: header)
      res = conn.get('users.list')
      if res.status == 200
        return JSON.parse(res.body)["members"]
      end
      return []
    rescue => e
      @logger.error("[Slack] Get User: #{e}")
    end
  end
end
