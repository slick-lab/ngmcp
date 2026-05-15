require "pg"
  DBU = PG.connect(ENV["DATABASE_URL"])

  DBU.exec <<-SQL
   CREATE TABLE IF NOT EXISTS users (
     id SERIAL PRIMARY KEY,
     email TEXT UNIQUE NOT NULL,
     name TEXT NOT NULL,
     created_at TIMESTAMP DEFAULT NOW(),
     updated_at TIMESTAMP DEFAULT NOW()
   )
  SQL

  DBU.exec <<-SQL
   CREATE TABLE IF NOT EXISTS ads (
     id SERIAL PRIMARY KEY,
     user_id INTEGER NOT NULL REFERENCES users(id),
     title TEXT NOT NULL,
     description TEXT NOT NULL,
     price TEXT NOT NULL,
     phone TEXT NOT NULL,
     photo_url TEXT NOT NULL,
     location TEXT NOT NULL,
     created_at TIMESTAMP DEFAULT NOW(),
     paid_at TIMESTAMP,
     is_active BOOLEAN NOT NULL DEFAULT false
   )
  SQL

  module Db
    def self.find_or_create_user(email : String, name : String)
      result = DBU.query_one?( "SELECT id FROM users WHERE email = $1", email, as: Int64)
      return result if result
      DBU.exec( "INSERT INTO users (email, name) VALUES ($1, $2)", email, name)
    end

    def self.get_id(email : String)
      DBU.query_one!( "SELECT id FROM users WHERE email = $1", email, as: Int64)
    end

    def self.expired_ads : Array(Int64)
      DBU.query_all("SELECT id FROM ads WHERE is_active = true AND paid_at <= NOW() - INTERVAL '7 days'", as: Int64)
    end

    def self.deactivate_ads(ids : Array(Int64))
      return if ids.empty?
      DBU.exec("UPDATE ads SET is_active = FALSE WHERE id IN (#{ids.join(",")})")
    end

    def self.activate_ads(user_id : String)
      DBU.exec("UPDATE ads SET is_active = true WHERE user_id = $1", user_id)
    end

    def self.get_all_ads
      DBU.query_all("SELECT * FROM ads", as: Hash(String, String))
    end

    def self.get_ads_by_user(user_id : String)
      DBU.query_all("SELECT * FROM ads WHERE user_id = $1", user_id, as: Hash(String, String))
    end

    def self.submit_ad(user_id : String, title : String, description : String, price : String, phone : String, photo_url : String, location : String)
      return nil if title.empty? || description.empty? || price.empty? || phone.empty? || photo_url.empty? || location.empty?
      if
       DBU.exec("SELECT * FROM ads WHERE user_id = $1", user_id)
       return nil
      end
      DBU.exec("INSERT INTO ads (user_id, title, description, price, phone, photo_url, location) VALUES ($1, $2, $3, $4, $5, $6, $7)", user_id, title, description, price, phone, photo_url, location)
    end
  end
