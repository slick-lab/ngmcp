require "http/client"
require "db"

def validate_token(token : String)
  response = HTTP::Client.get("https://oauth2.googleapis.com/tokeninfo?id_token=#{token}")
  if response.status_code == 200
   user_data = JSON.parse(response.body)
   email = user_data["email"].as_s
   name = user_data["name"]?.try &.as_s || email
   success, error = Db.find_or_create_user(email, name)
   if success == true 
     user_id = Db.get_id(email)
     {"success": "true", "status": "okay", "id": "#{user_id}"}
   end 
 else 
  {"success": "false", "message": "invalid token or possible network error"}
 end 
end 
  
  
  
