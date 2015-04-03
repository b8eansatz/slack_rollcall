require 'uri'
require 'net/http'
require 'json'
require 'dotenv'

def geturi(path, params)
  uri = URI::HTTPS.build(:host => "slack.com", :path => "#{path}")
  uri.query =  URI.encode_www_form(params)
  Net::HTTP.get(uri)
end

def channels_history(params)
  params[:channel] = ENV['CHANNEL_ID']
  params[:oldest] = Time.local(Time.now.year, Time.now.month, Time.now.day, ENV['OLD_HOUR'], ENV['OLD_MIN'], ENV['OLD_SEC']).to_i
  path = "/api/channels.history"
  geturi(path, params)
end

def channels_info(params)
  params[:channel] = ENV['CHANNEL_ID']
  path = "/api/channels.info"
  geturi(path, params)
end

def chat_postMessage(params)
  params[:username] = ENV['USERNAME']
  path = "/api/chat.postMessage"
  geturi(path, params)
end

def users_list(params)
  path = "/api/users.list"
  geturi(path, params)
end

def users_info(params)
  path = "/api/users.info"
  geturi(path, params)
end

Dotenv.load
token = ENV['TOKEN']
params = {
  :token => token,
}

#GETS INFORMATION ABOUT A CHANNEL
result_channel = JSON.parse(channels_info(params))

#FETCHES HISTORY OF MESSAGES & EVENTS FROM A CHARACTER
result_history = JSON.parse(channels_history(params))

#GETS USERS EVER POSTED ON THE CHANNEL
messages = result_history["messages"]
attend = Array.new
messages.each_with_index do |message, i|
  attend << "#{message["user"]}"
end
attend = attend.uniq

#GETS USERS NEVER POSTED ON THE CHANNEL
members = result_channel["channel"]["members"]
absent = members - attend

#SENDS MESSAGES TO EACH USERS
#attend.each_with_index do |user|
#  unless user.empty? == true then
#    params[:text] = "<@#{user}>: Good morning!"
#    chat_postMessage(params)
#  end
#end
absent.each_with_index do |user|
  params[:text] = "<@#{user}>: 今日のタスクは何ですかー？"
  chat_postMessage(params)
end
