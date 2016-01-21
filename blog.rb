require 'sqlite3'
require 'pry'

class Author

end

class Post
  attr_accessor :title, :content, :id
  @@db = SQLite3::Database.new("blog.db")

  def self.db
    DB[:conn]
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM posts
    SQL

    rows = db.execute(sql)
    rows.collect do |row|
      Post.new_from_row(row)
    end
  end

  def self.new_from_row(row)
    Post.new.tap do |p|
      p.id = row[0]
      p.title = row[1]
      p.content = row[2]
    end
  end

  def ==(other_post)
    self.id == other_post.id
  end

  def persisted?
    !!self.id
  end

  def save
    persisted? ? self.update : self.insert
  end

  private

    def update
      sql = <<-SQL
        UPDATE posts
        SET title = ?,
            content = ?
        WHERE id = ?
      SQL

      self.class.db.execute(sql, self.title, self.content, self.id)
    end

    def insert
      sql = <<-SQL 
        INSERT INTO posts (title, content) VALUES
        (?, ?) 
      SQL

      @@db.execute(sql, self.title, self.content)
    end
end

# hello_world = Post.new
# hello_world.title = "Hello World"
# hello_world.content = "Content of Post"
# hello_world.insert #=> Magically in the Database

Pry.start

# # CRUD
# # C - INSERT
# # R - SELECT
# # U - UPDATE
# # D - DELETE

# # SCHEMA
# # CREATE TABLE
# # DROP TABLE
# # ALTER TABLE

# db = SQLite3::Database.new("blog.db")

# def list(db)
#   sql = <<-SQL
#     SELECT * FROM posts
#   SQL

#   rows = db.execute(sql)
#   rows.each do |row|
#     id = row[0]
#     title = row[1]
#     content = row[2]
    
#     puts "#{id}. #{title}"
#   end
# end

# def delete(db)
#   puts "Which post do you want to delete?"
#   input = gets.strip

#   sql = <<-SQL
#     DELETE FROM posts
#     WHERE id = ?
#   SQL

#   db.execute(sql, input)
# end

# def update(db)
#   puts "Which post would you like to update"
#   a = gets.strip # 1

#   puts "Type in the title of your post"
#   c = gets.strip # New Title
#   puts "Type in the content of your post"
#   b = gets.strip # New Content

#   sql = <<-SQL
#     UPDATE posts
#     SET title = ?,
#         content = ?
#     WHERE id = ?
#   SQL

#   db.execute(sql, c, b)
# end

# def insert(db)
#   puts "Type in the title of your post"
#   title = gets.strip
#   puts "Type in the content of your post"
#   content = gets.strip
#   puts "What is the name of the author?"
#   author_name = gets.strip
  
#   sql = <<-SQL
#     INSERT INTO authors (name) VALUES (?)
#   SQL
#   db.execute(sql, author_name)

#   # Hey, give me the ID you assigned to that author?
#   author_id = db.execute("SELECT last_insert_rowid()")[0][0]

#   sql = <<-SQL
#     INSERT INTO posts (title, content, author_id) VALUES
#     (?, ?, ?) 
#   SQL

#   db.execute(sql, title, content, author_id)
# end

# def show(db)
#   # Ask you what blog post to show
#   puts "What post?"
#   post_id = gets.strip

#   sql = <<-SQL
#     SELECT * FROM posts WHERE id = ? LIMIT 1
#   SQL

#   post_row = db.execute(sql, post_id)[0]

#   post_title = post_row[1]
#   post_content = post_row[2]
#   post_author_id = post_row[3]

#   sql = <<-SQL
#     SELECT * FROM authors WHERE id = ? LIMIT 1
#   SQL

#   author_row = db.execute(sql, post_author_id)[0]
#   author_name = author_row[1]

#   puts "#{post_title}, by #{author_name}"
#   puts "#{post_content}"
#   # and then show the details of the blog post
#   # including it's author
# end

# def authors(db)
#   # List out all the others and the amount of posts
#   # they have
# end

# command = ""
# while command != "exit"
#   puts "Type in your command"
#   command = gets.strip
#   case command
#   when "list"
#     list(db)
#   when "insert"
#     insert(db)
#   when "delete"
#     delete(db)
#   when "update"
#     update(db)
#   when "show"
#     show(db)
#   when "authors"
#     authors(db)
#   end
# end
