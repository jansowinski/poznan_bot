require 'securerandom'
require 'redis'
require 'time'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'json'

$redis = Redis.new(host: 'redis', port: 6379)

class Emoji
  def failure
    return ['😏','😢','😭','🌧'].sample
  end
  def success
    return ["🎉", "💥","👍","🚀","💪"].sample
  end
  def error
    return ["😏","😢","😭","👎","️🌧","❗"].sample
  end
end

class Location
  attr_reader :voievodship, :shire, :town, :lat, :lng
  def initialize (lat,lng)
    @lat = lat
    @lng = lng
    @voievodship = nil 
    @shire = nil 
    @town = nil
    key = SecureRandom.hex(5)
    $redis.lpush('locations', "{\"Id\":\"#{key}\",\"Lat\":#{@lat},\"Lng\":#{@lng}}")
    sleep 0.1
    anwser = $redis.get(key)
    while anwser == nil
      anwser = $redis.get(key)
    end
    parsed_anwser = JSON.parse(anwser)
    @voievodship = parsed_anwser['Wojewodztwo']
    @shire = parsed_anwser['Powiat'].gsub('powiat ', '')
    @town = parsed_anwser['Gmina']
  end
end

class Meteo
  attr_reader :data, :floating_towns

  def initialize
    uri = URI.parse("http://www.meteo.pl/um/php/gpp/search.php")
    voievodships_response = Net::HTTP.get_response(uri).body
    voievodships_page = Nokogiri::HTML(voievodships_response)
    @data = {}
    @floating_towns = []
    voievodships = []
    voievodships_fullname = []
    voievodships_page.xpath("//select[@name='woj']/option").each do |voievodship|
      voievodships_fullname << voievodship.text.gsub(' ','').gsub("\n",'')
      voievodships << voievodship.xpath("@value").text
    end
    voievodships.each_with_index do |voievodship, index|
      @data[voievodships_fullname[index]] = {}
      shire_response = Net::HTTP.post_form(URI.parse('http://www.meteo.pl/um/php/gpp/next.php'),{'woj' => voievodship, 'litera' => ''})
      shire_page =  Nokogiri::HTML(shire_response.body)
      shire_page.xpath("//table/tr").each do |element|
        full_name = element.xpath("td[2]").text.split(', pow. ')
        next if full_name[0] == 'ZNALEZIONE MIEJSCOWOŚCI'
        if full_name[1] == nil
          @floating_towns << full_name[0] 
          @data[voievodships_fullname[index]][full_name[0]] = element.xpath("td[2]/a").xpath("@onclick").text.gsub('show_mgram(', '').gsub(')','')
        end
        if @data[voievodships_fullname[index]][full_name[1]] == nil
          @data[voievodships_fullname[index]][full_name[1]] = {}
        end
        @data[voievodships_fullname[index]][full_name[1]][full_name[0]] = element.xpath("td[2]/a").xpath("@onclick").text.gsub('show_mgram(', '').gsub(')','')
      end
    end
  end

  def get_image(location)
    voievodship = location.voievodship
    shire = location.shire
    town = location.town
    lat = location.lat
    lng = location.lng
    emoji = Emoji.new
    if voievodship == nil
      return "niestety, nie znam tej lokalizacji #{emoji.failure}"
    end
    if @floating_towns.include?(town)
      id = @data[voievodship][town]
      description = "#{voievodship.capitalize} - #{town}"
    else
      if @data[voievodship] != nil and @data[voievodship][shire] != nil and @data[voievodship][shire][town]
        id = @data[voievodship][shire][town] 
        description = "#{voievodship.capitalize} - pow. #{shire}, #{town}"
      elsif @data[voievodship] != nil and @data[voievodship][shire] != nil
        difference_hash = {}
        @data[voievodship][shire].each do |key, value|
          uri = URI.parse(URI.encode("https://maps.googleapis.com/maps/api/geocode/json?address=Poland,#{voievodship},#{shire},#{key}"))
          response = JSON.parse(Net::HTTP.get_response(uri).body)
          next if response['status'] == 'ZERO_RESULTS'
          gps = response['results'][0]['geometry']['location']
          lat_difference = (lat - gps['lat']).abs
          lng_difference = (lng - gps['lng']).abs
          difference = Math.sqrt((lat_difference*lat_difference)+(lng_difference*lng_difference))
          difference_hash[key] = difference
        end
        closest_city = difference_hash.key(difference_hash.values.min)
        id = @data[voievodship][shire][closest_city]
        description = "#{voievodship.capitalize} - #{closest_city}"
      else
        return "Niestety, nie znam tej lokalizacji #{emoji.failure}"
      end
    end
    uri = URI.parse("http://www.meteo.pl/um/php/meteorogram_id_um.php?ntype=0u&id=#{id}")
    response = Net::HTTP.get_response(uri).body
    x = response[/var act_x = (.*);var/,1]
    y = response[/var act_y = (.*);/,1]
    return [description, "http://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&fdate=#{date_setter}#{hour_num}&row=#{y}&col=#{x}&lang=pl"]
  end

  def date_setter
    if hour_num() == "18"
      return Time.now.strftime('%Y%m%d').to_i - 1
    else
      return Time.now.strftime('%Y%m%d')
    end
  end

  def hour_num
    hour_now = Time.now.hour
    if hour_now >= 7 and hour_now < 13
      return "00"
    elsif hour_now >= 13 and hour_now < 19
      return "06"
    elsif hour_now >= 19 or (hour_now  >= 0 and hour_now < 1)
      return "12"
    elsif hour_now >= 1 and hour_now < 7
      return "18"
    else
      return "00"
    end
  end
  private :date_setter, :hour_num
end
