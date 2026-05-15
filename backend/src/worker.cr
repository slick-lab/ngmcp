require "./db"

def start_worker
  puts "starting background worker"
  loop do
    begin
     expired_ads = Db.working_expiring_ads
     if expired_ads.empty?
       puts "no expired ads found"
     else
       puts "found expired ads deactivating.."
       Db.deactivate_ads(expired_ads)
       puts "deactivated #{expired_ads.join(", ")} ads"
     end
     sleep 300
   rescue e
     puts "error: #{e.message}"
   end
  end
end
