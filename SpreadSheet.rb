require 'logger'
require 'google_drive'
require './SecretManager.rb'

class SpreadSheet
  attr_accessor :ws
  def initialize(sheet_id)
    begin
      @logger = Logger.new($stdout)

      session = GoogleDrive::Session.from_config("config.json")

      @ws = session.spreadsheet_by_key(sheet_id)
    rescue => e
      @logger.error("[SpreadSheet] Initialize: #{e}")
    end
  end
end
