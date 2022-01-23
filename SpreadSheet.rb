require 'logger'
require 'google_drive'
require './SecretManager.rb'

module SpreadSheet
  def self.init(sheet_id, sheet_num)
    begin
      @logger = Logger.new($stdout)

      session = GoogleDrive::Session.from_config("config.json")

      return session.spreadsheet_by_key(sheet_id).worksheets[sheet_num]
    rescue => e
      @logger.error("[SpreadSheet] Initialize: #{e}")
    end
  end

  def self.write(config = {})
    return if config
    begin
      sheet_id = config[:sheet_id]
      sheet_num = config[:sheet_num]
      row = config[:row]
      col = config[:col]
      value = config[:value]

      ws = init(sheet_id, sheet_num)

      ws[row, col] = value
      ws.save
    rescue => e
      @logger.error("[SpreadSheet] Initialize: #{e}")
    end
  end
end
