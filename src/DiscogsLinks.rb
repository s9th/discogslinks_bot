require 'telegram/bot'
require 'discogs-wrapper'
require 'nokogiri'
require 'httparty'
require 'dotenv'
require_relative 'src/providers/DiscogsRelease.rb'
require_relative 'src/providers/BandcampRelease.rb'

LinksNumber = 5

def getmusiclinks(provider)
    case provider
    when "discogs"
        DiscogsRelease.random_release(LinksNumber).map{|release| release.to_s}.join("\n")
    when "bandcamp"
        BandcampRelease.random_release(LinksNumber).map{|release| release.to_s}.join("\n")
    end
end


Telegram::Bot::Client.run(ENV["TelegramToken"]) do |bot|
    bot.listen do |message|
        case message.text
        when '/music'
            bot.api.send_message(chat_id: message.chat.id, text: getmusiclinks("discogs"), parse_mode: 'HTML', disable_web_page_preview: true)
        when '/music bc'
            bot.api.send_message(chat_id: message.chat.id, text: getmusiclinks("bandcamp"), parse_mode: 'HTML', disable_web_page_preview: true)
        end
    end
end