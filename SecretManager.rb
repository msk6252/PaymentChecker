require 'aws-sdk-secretsmanager'
require 'logger'
require 'json'

class SecretManager
  def initialize(secret_id)
    begin
      @logger = Logger.new($stdout)
      @client = Aws::SecretsManager::Client.new(region: "ap-northeast-1")
      @secret_id = secret_id
    rescue => e
      @logger.error("SecretManager: #{e}")
    end
  end

  def get_secret(key)
    begin
      secret = @client.get_secret_value(secret_id: @secret_id)
      return JSON.load(secret.secret_string)[key]
    rescue => e
      @logger.error("SecretManager: #{e}")
    end
  end
end
