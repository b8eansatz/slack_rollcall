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
  params[:oldest] = Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0).to_i
  path = "/api/channels.history"
  geturi(path, params)
end

def channels_info(params)
  params[:channel] = ENV['CHANNEL_ID']
  path = "/api/channels.info"
  geturi(path, params)
end

def chat_postMessage(params)
  #params[:channel] = ENV["CHANNEL"]
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
#oldest = Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0).to_i
params = {
  :token => token,
}

result_channel = JSON.parse(channels_info(params))
result_history = JSON.parse(channels_history(params))
messages = result_history["messages"]
puts "#{result_channel}"
#puts messages.length
#puts "#{messages[0]}"
#puts messages[0]["user"]

attend = Array.new
#puts "#{attend}"
messages.each_with_index do |message, i|
  puts message["user"]
  attend << "#{message["user"]}"
end

attend = attend.uniq
#attend.delete("")
#puts "ATTENDS = #{attend}"
members = result_channel["channel"]["members"]
#puts "MEMBERS = #{members}"
absent = members - attend
#puts "ABSENTS = #{absent}"

attend.each_with_index do |user|
  unless user.empty? == true then
    params[:text] = "<@#{user}>: Good morning!"
    chat_postMessage(params)
  end
end

#absent.each_with_index do |user|
#  params[:text] = "<@#{user}>: How's it going?"
#  chat_postMessage(params)
#end

#puts "MEMBERS = #{result_channel["channel"]["members"]}"
#puts "#{result_history}"
#puts "#{result_history.assoc("messages")}"
#puts "MESSAGES = #{result_history["messages"]}"
