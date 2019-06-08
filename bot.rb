require 'slack-ruby-client'
require 'uri'
require 'net/http'
require 'dotenv'

Dotenv.load('./.env')

SEARCH_IMAGE_URL_BASE = "https://www.googleapis.com/customsearch/v1?key=#{ENV['SEARCH_ENGINE_API_KEY']}&cx=#{ENV['SEARCH_ENGINE_ID']}&searchType=image&num=1&q="

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts 'success'
end

client.on :message do |data|
  case data.text
  when /ratneko bot wiki */ then
    keyword = data.text.split(/ /)[3]
    wiki_link = 'https://ja.wikipedia.org/wiki/' + URI.encode(keyword)

    client.web_client.chat_postMessage(channel: data.channel, text: wiki_link, unfurl_links: true, unfurl_media: true)
  when /ratneko bot image */ then
    keywords = data.text.split(/ /)[3..-1].join('+')
    uri = URI.parse(URI.escape(SEARCH_IMAGE_URL_BASE + keywords))
    res = Net::HTTP.get_response(uri)
    image_link = JSON.parse(res.body)["items"][0]["link"]

    client.web_client.chat_postMessage(channel: data.channel, text: image_link, unfurl_links: true, unfurl_media: true)
  end
end

Process.daemon
client.start!
