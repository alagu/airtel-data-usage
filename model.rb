require  'dm-migrations'
class Usage
  include DataMapper::Resource

  property :id,         Serial

  property :consumed,  Float
  property :phone, Integer,  :unique_index => :u
  property :available, Float
  property :total, Float
  property :time, DateTime,  :unique_index => :u
end

DataMapper.finalize
DataMapper.auto_upgrade!