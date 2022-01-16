require 'aws-sdk-secretsmanager'
require 'logger'
require 'json'

class SecretManager
  def initialize(secret_id)
    @logger = Logger.new($stdout)
    @secret_id = secret_id
  end

  def get_secret(key)
    begin
      scm = Aws::SecretManager::Client.new(region: "ap-northeast-1")
      secret = scm.get_secret_value(secret_id: @secret_id)
      return JSON.load(secret.secret_string)[key]
    rescue => e
      @logger.error(e)
    end
  end
end
