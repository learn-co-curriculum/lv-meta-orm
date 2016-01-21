# we need a database

# we need a table to store blog posts

# we need a Post class

#   were gonna need to save blog posts

class Post
  @@all = []
  attr_accessor :id, :title, :content

  def self.all
    rows = DB.execute("SELECT * FROM posts")
    # [[1, "Default Title", nil]]

    rows.collect do |row|
      p = Post.new
      p.id = row[0]
      p.title = row[1]
      p.content = row[2]
      p
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      content TEXT
    );
    SQL

    DB.execute(sql)
  end

  def ==(other_post)
    self.id == other_post.id
  end

  def save
    sql = <<-SQL
      INSERT INTO posts (title, content) VALUES (?, ?)
    SQL
    DB.execute(sql, self.title, self.content)

    id = DB.execute("SELECT last_insert_rowid() FROM posts;").flatten.first
    self.id = id
  end
end

