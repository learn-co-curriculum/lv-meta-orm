class Author

  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :state => "TEXT",
    :city => "TEXT",
    :age => "INTEGER"
  }

  # DO NOT EDIT ANYTHING BELOW THIS
  ATTRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

  def destroy
    sql = <<-SQL
      DELETE FROM #{self.class.table_name} WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.id)
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.find(id)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE id = ?
    SQL

    rows = DB[:conn].execute(sql, id)
    self.reify_from_row(rows.first)
  end

  def self.reify_from_row(row)
    self.new.tap do |p|
      ATTRIBUTES.keys.each.with_index do |attribute_name, i|
        p.send("#{attribute_name}=", row[i])
      end
    end
  end

  def self.create_sql
    ATTRIBUTES.collect{|attribute_name, schema| "#{attribute_name} #{schema}"}.join(",")
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.table_name} (
        #{self.create_sql}
      )
    SQL

    DB[:conn].execute(sql)
  end

  def ==(other_post)
    self.id == other_post.id
  end

  def save
    # if the post has been saved before, then call update
    persisted? ? update : insert
    # otherwise call insert
  end

  def persisted?
    !!self.id
  end

  def self.attribute_names_for_insert
    ATTRIBUTES.keys[1..-1].join(",")
  end

  def self.question_marks_for_insert
    (ATTRIBUTES.keys.size-1).times.collect{"?"}.join(",")
  end

  def attribute_values
    ATTRIBUTES.keys[1..-1].collect{|attribute_name| self.send(attribute_name)}
  end

  def self.sql_for_update
    ATTRIBUTES.keys[1..-1].collect{|attribute_name| "#{attribute_name} = ?"}.join(",")
  end

  private
    def insert
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (#{self.class.attribute_names_for_insert}) VALUES (#{self.class.question_marks_for_insert})
      SQL

      DB[:conn].execute(sql, *attribute_values)
      self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
    end

    def update
      sql = <<-SQL
        UPDATE posts SET #{self.class.sql_for_update} WHERE id = ?
      SQL

      DB[:conn].execute(sql, *attribute_values, self.id)
    end


end
