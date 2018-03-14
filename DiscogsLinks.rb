require 'telegram/bot'
require 'discogs-wrapper'
require 'nokogiri'
require 'httparty'
require 'dotenv'
require_relative 'providers/DiscogsRelease.rb'
require_relative 'providers/BandcampRelease.rb'

LinksNumber = 5

def getmusiclinks(provider)
    provider.random_release(LinksNumber).map{|release| release.to_s}.join("\n")
end

Telegram::Bot::Client.run(ENV["TelegramToken"]) do |bot|
    provider = nil
    bot.listen do |message|
        case message.text
        when '/music'
            provider = DiscogsRelease
        when '/music bc'
            provider = BandcampRelease
        end
        bot.api.send_message(chat_id: message.chat.id, text: getmusiclinks(provider), parse_mode: 'HTML', disable_web_page_preview: true)
    end
end