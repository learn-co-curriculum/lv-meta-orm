class Author
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :state => "TEXT",
    :city => "TEXT",
    :age => "INTEGER"
  }

  include Persistable::InstanceMethods # Can I hook into this moment in time?
  extend Persistable::ClassMethods

end
