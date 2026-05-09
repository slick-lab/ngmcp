require "./db"

def start_worker
  puts "starting background worker"
  loop do 
    begin
     expired_ads = Db.working_expired_ads
       if expired_ads.nil?
        puts "no expired ads found"
      else 
        puts "found expired ads deactivating.."
        Db.deactivate_ads(expired_ads)
        puts "deactivated ads for #{expired_ads}"
     end
    rescue ex
     puts "worker error #{ex.message}"
    end
    sleep 2.minute
  end
end
