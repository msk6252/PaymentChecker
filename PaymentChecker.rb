require 'logger'
require './SecretManager.rb'
require './Slack.rb'
require './SpreadSheet.rb'
require './Stripe.rb'

class PaymentChecker
  # ２行目から入力開始
  DEFAULT_ROW = 1
  COL = { NAME: 1, SLACK_NAME: 2, EMAIL: 3, PHONE: 4, IS_PAY: 5, AMOUNT: 6 }

  def initialize
    begin
      ENV['TZ'] = 'Asia/Tokyo'
      @logger = Logger.new($stdout)
      @secret = SecretManager.new("PaymentChecker")
      @stripe = StripeModule.new
      @slack = Slack.new
      sheet_id = @secret.get_secret("GOOGLE_SHEET_KEY")
      @spread = SpreadSheet.new(sheet_id)
    rescue => e
      @logger.error("[PaymentChecker] Initialize: #{e}")
    end
  end

  def run
    @logger.info("===== 【開始】支払状況確認シートの作成 =====")
    # テンプレートシートからコピー
    copy_sheet_from_template

    # スプレッドシートの指定
    sheet = @spread.ws.worksheets[0]

    # SlackUserのシートへ書き込み
    user_write_sheet(sheet)

    @logger.info("===== 【終了】支払状況確認シートの作成 =====")
  end

  private

  def copy_sheet_from_template
    # 年/月のシートをテンプレートからコピー
    year_month = Time.now.strftime("%Y/%m")

    @logger.info("=== #{year_month}分のシートをコピーします。 ===")
    new_sheet = @spread.ws.copy("#{year_month}分")

    # コピーしたシートで作業をする
    @spread = SpreadSheet.new(new_sheet.id)
  end

  def user_write_sheet(sheet)
    @logger.info("=== ユーザーの情報をスプレッドシートに書き込みます。 ===")
    slack_users = @slack.get_users_list

    return if slack_users.empty?

    slack_users.each_with_index do | user, idx |
      row = DEFAULT_ROW + idx
      next if user["deleted"] != false || user["is_bot"] == true || user["name"] == "slackbot"

      payment = get_payment(user)
      sheet[row, COL[:NAME]]       = user["real_name"] || ""
      sheet[row, COL[:SLACK_NAME]] = user["profile"]["display_name"] || "-"
      sheet[row, COL[:EMAIL]]      = user["profile"]["email"] || "-"
      sheet[row, COL[:PHONE]]      = !user["profile"]["phone"].empty? ? user["profile"]["phone"] : "-"
      sheet[row, COL[:IS_PAY]]     = payment.nil? ? '×' : payment.paid? ? '◯' : '×'
      sheet[row, COL[:AMOUNT]]     = payment.nil? ?  0  : payment.amount_captured
    end
    sheet.save
  end

  def get_payment(user)
    payments = @stripe.get_payments
    payments.each do | pay |
      if pay["billing_details"]["email"] == user["profile"]["email"] ||
         pay["billing_details"]["phone"] == user["profile"]["phone"]
        return pay
      end
    end
    nil
  end
end
