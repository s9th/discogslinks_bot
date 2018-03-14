require 'telegram/bot'
require 'discogs-wrapper'
require 'nokogiri'
require 'httparty'
require 'dotenv'
require_relative 'providers/DiscogsRelease.rb'
require_relative 'providers/BandcampRelease.rb'

LinksNumber = 5
commandMapper = { '/music' => DiscogsRelease,'/music bc' => BandcampRelease }

def getmusiclinks(provider)
    provider.random_release(LinksNumber).map{|release| release.to_s}.join("\n")
end

Telegram::Bot::Client.run(ENV["TelegramToken"]) do |bot|
    bot.listen do |message|
        provider = commandMapper[message.text]
        if (provider)
            bot.api.send_message(chat_id: message.chat.id, text: getmusiclinks(provider), parse_mode: 'HTML', disable_web_page_preview: true)
        end
    end
end