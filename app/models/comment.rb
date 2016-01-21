class Comment
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :content => "TEXT",
  }

  include Persistable::InstanceMethods
  extend Persistable::ClassMethods
end
