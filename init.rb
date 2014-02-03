 # If you want the logs displayed you have to do this before the call to setup
  DataMapper::Logger.new($stdout, :debug)

  DataMapper.setup(:default, "sqlite3://#{File.expand_path(File.dirname(__FILE__))}/usage.sqlite")