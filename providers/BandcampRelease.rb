class BandcampRelease

  HostURL = "http://dx3x.com/randcamp/?"

  def self.random_release(n)
    i = 0
    random_releases = []
    while i < n
      release = self.new
      if release.valid?
        random_releases << release
        i+=1
      end
    end
    random_releases
  end

  # release is valid if it does not redirect to another page
  def valid?
    page = HTTParty.get(url)
    url == page.request.last_uri.to_s
  end

  # we get a random url here from the randomizer and change it to https
  def random_url
    page = HTTParty.get(HostURL)
    doc = Nokogiri.parse(page.body)
    links = doc.css('a')
    links = links.map { |link| link.attribute('href').to_s }.uniq.sort.delete_if { |h| !h.include?(".bandcamp") }
    links.first.strip.sub("http","https")
  end

  # do it once because otherwise it will repeat itself
  def url
    @url ||= random_url
  end
  
  def to_s
    url
  end

end