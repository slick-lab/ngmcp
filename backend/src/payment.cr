require "http/client"
require "openssl/hmac"
require "json"

SECRET_KEY = ENV["PAYSTACK_SK"]


module PaystackWebhook

  def self.verify_signature(payload : String, signature : String) : Bool
    expected = OpenSSL::HMAC.hexdigest(:sha512, SECRET_KEY, payload)
    expected == signature
  end

  def self.process(event : String, data : JSON::Any)
    case event
     when "charge.success"
     process_charge_success(data)
     when "invoice.payment_succeeded"
      process_invoice_succeeded(data)
    else
    put "error unhandled event #{event}"
  end
 end

 def self.process_charge_success(data : JSON::Any)
   refrence = data["refrence"].as_s
   amount = data["amount"].as_i
   paid_at = Time.parse_rfc3339(data["paid_at"].as_s)
   customer_email = data["customer"]["email"].as_s
   id = Db.get_id(customer_email)
   update = Db.activate_ads(id)
   if update
    {"success": true, "message": "updated user ads for #{customer_email}"}.to_json
   else
    {"error": "failed to update user ads for #{customer_email}"}.to_json
   end
 end

 def self.process_invoice_succeeded(data : JSON::Any)
   refrence = data["refrence"].as_s
   puts "invoice payment succeeded for #{refrence}"
 end
end
