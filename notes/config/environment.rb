require 'bundler'
Bundler.require


DB = SQLite3::Database.new "db/blog.db"

require_relative '../app/models/post'

