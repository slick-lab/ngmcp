def validate_token(token : String)
  response = HTTP::Client.get("https://oauth2.googleapis.com/tokeninfo?id_token=#{token}")
  
  if response.status_code == 200
    user_data = JSON.parse(response.body)
    email = user_data["email"].as_s
    name = user_data["name"]?.try &.as_s || email
    
    Db.find_or_create_user(email, name)
    user_id = Db.get_id(email)
    
    {"success": true, "user_id": user_id, "email": email}.to_json
  else
    {"success": false, "message": "Invalid Google token"}.to_json
  end
end
