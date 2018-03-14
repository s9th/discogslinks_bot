class BandcampRelease

  HostURL = "http://dx3x.com/randcamp/?"

  def self.random_release(n)
    i = 0
    random_releases = []
    while i < n
      release = self.new
      random_releases << release
      i+=1
    end
    random_releases
  end

  def random_url
    page = HTTParty.get(HostURL)
    doc = Nokogiri.parse(page.body)
    links = doc.css('a')
    links = links.map { |link| link.attribute('href').to_s }.uniq.sort.delete_if { |h| !h.include?(".bandcamp") }
    links.first.strip
  end

  def to_s
    random_url
  end

end