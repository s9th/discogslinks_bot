require 'telegram/bot'
require 'discogs-wrapper'
require 'nokogiri'
require 'httparty'
require 'dotenv'


LinksNumber = 5

class DiscogsRelease

    HostURL = 'https://www.discogs.com'
    APIURL = 'https://api.discogs.com'

    # generate a number of random valid release ids
    def self.random_release(n)
        i = 0
        random_releases = []
        latest_release = latest_release_id.to_i
        while i < n
            release_number = Random.rand(latest_release + 1)
            release = self.new(release_number)
            if release.valid?
                random_releases << release
                i+=1
            end
        end
        random_releases
    end

    def self.latest_release_id
        page = HTTParty.get("#{HostURL}/search/?sort=date_added%2Cdesc&type=release")
        doc = Nokogiri.parse(page.body)
        links = doc.css('a')
        links = links.map { |link| link.attribute('href').to_s }.uniq.sort.delete_if { |h| !h.include?("/release/") }
        links.first.split("/").last
    end

    def initialize(release_id)
        @id = release_id
    end

    # Discogs API authentication
    def wrapper
        @wrapper ||= Discogs::Wrapper.new("discogslinks_bot", user_token: ENV["DiscogsToken"])
    end

    # get release data from Discogs API
    def release_data
        @release_data ||= wrapper.get_release(@id)
    end

    # release is valid if it has both title and either genres or styles
    def valid?
        release_data.title && (release_data.genres || release_data.styles)
    end

    # convert object to string displayed in chat
    def to_s
        "#{url} #{artists} - #{album} | #{tags}"
    end

    # return release URL
    def url
        "#{HostURL}/release/#{@id}"
    end

    # return artists
    def artists
        return unless valid?
        release_data.artists.map{|r| r.name}.join(', ')
    end

    # return album
    def album
        return unless valid?
        release_data.title
    end

    #return release tags
    def tags
        return unless valid?
        label, tags = if release_data.styles
            ['Styles: ', release_data.styles]
        else
            ['Genres: ', release_data.genres]
        end

        label + tags.join(', ')
    end

end

def getmusiclinks
    DiscogsRelease.random_release(LinksNumber).map{|release| release.to_s}.join("\n")
end


Telegram::Bot::Client.run(ENV["TelegramToken"]) do |bot|
    bot.listen do |message|
        if message.text == '/music'
            bot.api.send_message(chat_id: message.chat.id, text: getmusiclinks, parse_mode: 'HTML', disable_web_page_preview: true)
        end
    end
end