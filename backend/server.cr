require "kemal"
require "./src/*"


spawn do
  start_worker
end

post "/auth/google" do |env|
  token = env.params.json["token"].as(String)
  validate_token(token)
end

get "/ads" do |env|
  ads = Db.get_all_ads
  ads.to_json
end

get "/ads/user" do |env|
  user_id = env.params.query["user_id"].as(String)
  ads = Db.get_ads_by_user(user_id)
  ads.to_json
end

post "/ads/submit" do |env|
  user_id = env.params.json["user_id"].as(String)
  title = env.params.json["title"].as(String)
  description = env.params.json["description"].as(String)
  price = env.params.json["price"].as(String)
  phone = env.params.json["phone"].as(String)
  photo_url = env.params.json["photo_url"].as(String)
  location = env.params.json["location"].as(String)
  Db.submit_ad(user_id, title, description, price, phone, photo_url, location)
  {"success" => true}.to_json
end

post "/webhook" do |env|
  payload = env.request.body.gets_to_end
  signature = env.request.headers["x-paystack-signature"].as_s
  if PaystackWebhook.verify_signature(payload, signature)
    event = JSON.parse(payload)["event"].as_s
    data = JSON.parse(payload)["data"]
    PaystackWebhook.process(event, data)
    {"success": true}.to_json
  else
    {"error": "invalid signature"}.to_json
  end
end

Kemal.run
puts "Server is running on http://localhost:3000"