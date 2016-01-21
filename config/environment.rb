require 'bundler'
Bundler.require

DB = {:conn => SQLite3::Database.new("db/blog.db")}

require_all 'app'