require_relative 'config/environment'

desc 'Will load a console with the environment'
task :console do
  def reload!
    load_all 'app'
  end
  
  Pry.start
end


