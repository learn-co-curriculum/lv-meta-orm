module Persistable
  module ClassMethods
    def self.extended(base) # HOOK / LifeCycle / Callback
      puts "#{base} has been extended by #{self}"
      base.attributes.keys.each do |attribute_name|
        attr_accessor attribute_name
      end
    end

    def attributes
      self::ATTRIBUTES
    end

    def table_name
      "#{self.to_s.downcase}s"
    end

    def create(attributes_hash)
      self.new.tap do |p|
        attributes_hash.each do |attribute_name, attribute_value|
          p.send("#{attribute_name}=", attribute_value)
        end
        p.save
      end
    end

    def attribute_names_for_insert
      self.attributes.keys[1..-1].join(",")
    end

    def question_marks_for_insert
      (self.attributes.keys.size-1).times.collect{"?"}.join(",")
    end

    def sql_for_update
      self.attributes.keys[1..-1].collect{|attribute_name| "#{attribute_name} = ?"}.join(",")
    end

    def find(id)
      sql = <<-SQL
        SELECT * FROM #{self.table_name} WHERE id = ?
      SQL

      rows = DB[:conn].execute(sql, id)
      if rows.first
        self.reify_from_row(rows.first)
      else
        nil
      end
    end

    def reify_from_row(row)
      self.new.tap do |p|
        self.attributes.keys.each.with_index do |attribute_name, i|
          p.send("#{attribute_name}=", row[i])
        end
      end
    end

    def create_sql
      self.attributes.collect{|attribute_name, schema| "#{attribute_name} #{schema}"}.join(",")
    end

    def create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS #{self.table_name} (
          #{self.create_sql}
        )
      SQL

      DB[:conn].execute(sql)
    end
  end

  module InstanceMethods

    def self.included(base) # HOOK / LifeCycle / Callback
      puts "#{base} has mixed in #{self}"
    end

    def destroy
      sql = <<-SQL
        DELETE FROM #{self.class.table_name} WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.id)
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

    def insert
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (#{self.class.attribute_names_for_insert}) VALUES (#{self.class.question_marks_for_insert})
      SQL
      # INSERT INTO posts (title, content) VALUES (?, ?)

      DB[:conn].execute(sql, *attribute_values)
      self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
    end

    def update
      sql = <<-SQL
        UPDATE posts SET #{self.class.sql_for_update} WHERE id = ?
      SQL

      DB[:conn].execute(sql, *attribute_values, self.id)
    end

    def attribute_values
      self.class.attributes.keys[1..-1].collect{|attribute_name| self.send(attribute_name)}
    end
  end
end
