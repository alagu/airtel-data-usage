require 'rubygems'
require 'data_mapper'
require 'mechanize'
require 'xmlsimple'
require 'time'
require 'gruff'
require './init'
require './model'

def usage_data(phone, password)
  browser = Mechanize.new { |agent|
    agent.user_agent_alias = 'Windows Chrome'
  }

  login = 'https://www.airtel.in/pkmslogin.form'
  usage = 'https://www.airtel.in/myaccount/MyAccount/KCIDataSrvl'

  data = {
    'password' => password,
    'login-form-type' => 'pwd',
    'username' => phone
  }

  page = browser.post login, data

  page = browser.post usage, { 'msisdn' => phone}
  usage_xml = XmlSimple.xml_in(page.body)

  consumed  = usage_xml['consumedUsage'].first
  available = usage_xml['freeUsage'].first
  total     = usage_xml['totalUsage'].first
  date      = usage_xml['reportDate'].first
  hour      = usage_xml['reportHour'].first
  time      = DateTime.parse(date + " " + hour)

  puts "Consumed Usage: #{consumed}MB"
  puts "Available: #{available}MB"
  puts "Total Quota: #{total}MB"
  puts "Time : #{time}"

  {
    :phone => phone,
    :consumed => consumed,
    :available => available,
    :time => time,
    :total => total
  }
end

def draw_graphs
  g = Gruff::StackedArea.new
  g.title = "Airtel Usage for #{Usage.first.phone}"
  labels = {}
  consumed = []
  available = []
  Usage.all.each_with_index do |usage, index|
    labels[index] = usage.time.strftime("%d/%m %l%P")
    consumed.push usage.consumed
    available.push usage.available
  end
  g.labels = labels
  g.data :consumed, consumed
  g.data :available, available
  g.write('usage_all.png')

end


if ARGV.length != 1
  puts "Invalid format"
  puts "$ ruby airtel.rb phonenumber:password"
  puts "Example: ruby airtel.rb 9986016485:mypassword"
  exit
else
  phone, password = ARGV.first.split(':')
  data = usage_data(phone, password)

  begin
    usage_data = Usage.create(data)
    draw_graphs()
  rescue
    puts "Already inserted"
  end
end
