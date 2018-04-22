require 'time'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'addressable/uri'
require 'open-uri'
require 'json'

class Cinema
  attr_reader :theatres

  def initialize
    @urls = {"apolloUrl" => ["Apollo-70", "Kino Apollo"],
            "bulgarska19Url" => ["Bu%C5%82garska+19-1618", "Kino Bułgarska 19"],
            "charlieUrl" => ["Charlie+Monroe+Kino+Malta-1499", "Kino Charlie Monroe"],
            "kinepolisUrl" => ["Cinema+City+Kinepolis-624", "Cinema City Kinepolis"],
            "plazaUrl" => ["Cinema+City+Plaza-568", "Cinema City Plaza"],
            "multikino51Url" => ["Multikino+51-203", "Multikino 51"],
            "multikinoMaltaUrl" => ["Multikino+Malta-1434","Multikino Malta"],
            "multikinoBrowarUrl" => ["Multikino+Stary+Browar-633", "Multikino Stary Browar"],
            "muzaUrl"=> ["Muza-75", "Kino Muza"],
            "palacoweUrl" => ["Kino+Pa%C5%82acowe-1854", "Nowe Kino Pałacowe"],
            "rialtoUrl" => ["Rialto-78", "Kino Rialto"],
            "heliosUrl" => ["Helios-1943", "Kino Helios"]}
    @theatres = []
    @urls.each do |key, value|
      @theatres << (value[1].split(" ") - ["Multikino", "Kino", "Cinema", "City", "Nowe", "Poznań"]).join(" ")
    end
    @theatres.map(&:downcase)
  end


  def seanses(cinema_name="wszystkie", day=0)
    if day.to_i > 7 or day.to_i < 0
      day = 0
    end
    cinema_url = set_cinema(cinema_name)
    if cinema_url == "0"
      return everything(@urls, day.to_s)
    else
      return returner(assigner(cinema_url[0], day.to_s), cinema_url[1])
    end
  end

  def set_cinema(cinema)
    hash = {
        "apollo" => @urls["apolloUrl"],
        "bulgarska" => @urls["bulgarska19Url"],
        "charlie" => @urls["charlieUrl"],
        "kinepolis" => @urls["kinepolisUrl"],
        "plaza" => @urls["plazaUrl"],
        "51" => @urls["multikino51Url"],
        "malta" => @urls["multikinoMaltaUrl"],
        "browar" => @urls["multikinoBrowarUrl"],
        "muza" => @urls["muzaUrl"],
        "pałacowe" => @urls["palacoweUrl"],
        "rialto" => @urls["rialtoUrl"],
        "helios" => @urls["heliosUrl"],
        "wszystkie" => "0",
    }
    return hash[cinema.to_s]
  end

  def assigner (url_link, day)
    uri = URI.parse("http://www.filmweb.pl/showtimes/Pozna%C5%84/#{url_link}?day=#{day.to_s}")
    response = Net::HTTP.get_response(uri).body
    return Nokogiri::HTML(response)
  end

  def returner(assigned, cinema_name)

    cinema_div = assigned.xpath("//ul[@class='cinema-films']/li")
    array = []
    array << "#{cinema_name}\n"
    cinema_div.each do |child|
      time_array = []
      title = child.xpath("div[@class='filmBox']/div/div[@class='filmPreview__card']/div/div/a/h3[@class='filmPreview__title']").text
      child.css(".seances-table").xpath("div/div/ul/li/span").each do |item|
        time_array << item.text
      end
      array_temp = []
      array_temp << title
      array_temp << time_array.join(" ")
      array << array_temp.join(" / ")
    end
    return array
  end

  def everything(u, day)
    array = []
    u.each do |key, item|
      a = returner(assigner(item[0], day.to_s), item[1])
      array << a.join("\n")
    end
    return array
  end
end

class Movies
  attr_reader :movies, :update

  def initialize
    @url = "http://www.filmweb.pl/showtimes/Pozna%C5%84"
    get_movies_list
  end


  def movies
    string = ""
    @movies.each do |movie|
      string += "#{movie.filmweb_score} #{movie.metacritic_score} #{movie.rotten_tomatoes_score} / _#{movie.title}_\n"
    end
    return string
  end

  def update
    get_movies_list
  end

  def seanses (argument)
    movie = search(argument)
    return "" if movie == nil
    message = "#{movie.filmweb_score} #{movie.metacritic_score} #{movie.rotten_tomatoes_score} / *#{movie.title.upcase}*"
    movie.hours.each do |cinema, variants|
      message += "\n*#{cinema.gsub(' (Poznań)','')}*\n"
      variants.each do |variant, hours|
        dots = variant != "" ? ': ' : '' 
        message += variant + dots + hours.join(' ') + "\n"
      end
    end
    return message
  end

  def get_movies_list
    @movies = []
    uri = URI.parse(@url)
    response = Net::HTTP.get_response(uri).body
    movie_list = response.scan(/<li data-popularity(.+?)<\/li>/)
    movie_list.each do |item|
      item = item[0].force_encoding(Encoding::UTF_8)
      name = /<a class=\"name.*\"> (.+?)<\/a><div/.match(item)[1]
      filmweb_link = /href=\"(\/film.+?)\"/.match(item)
      if filmweb_link != nil
        @movies << Movie.new(name, filmweb_link[1])
      end
    end

  end

  def search (phrase)
    phrase.downcase!
    @movies.each do |movie|
      return movie if movie.title.downcase.include?(phrase)
    end
    return nil
  end

  private :search, :get_movies_list
end

class Movie
  attr_reader :filmweb_score, :metacritic_score, :rotten_tomatoes_score, :filmweb_link, :hours, :title, :original_title
  def initialize(title, filmweb_link)
    @title = title
    @filmweb_link = "http://www.filmweb.pl#{filmweb_link}"
    parse_filmweb_data
    set_year
    set_metacritic_score
    set_rotten_tomatoes_score
  end
  def update_hours
    parse_filmweb_data
  end
  def set_year
    year = /-\d\d\d\d-/.match(@filmweb_link).to_s.gsub!('-', '')
    @year = year
  end
  def set_metacritic_score
    name_to_search = "#{@original_title}"
    uri = URI.parse("http://www.metacritic.com/autosearch")
    http = Net::HTTP.new(uri.host,uri.port)
    request = Net::HTTP::Post.new(uri.path, initheader = {
      "Referer" => "http://www.metacritic.com/autosearch",
      "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
      "Host" => "www.metacritic.com",
      "User-Agent" => "MetacriticUserscript Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0",
      "X-Requested-With" => "XMLHttpRequest"
    })
    request.body = "search_term=#{URI.escape(name_to_search)}&image_size=98&search_each=1&sort_type=popular"
    response = http.request(request)
    result = JSON.parse(response.body)
    min_time_difference = 100
    result['autoComplete']['results'].each do |item|
      if item['metaScore'] != nil and item['refType'] == "Movie" 
        time_difference = (item['itemDate'].to_i - @year.to_i).abs
        if time_difference < min_time_difference
          min_time_difference = time_difference
          @metacritic_score = "\u24C2 #{item['metaScore']}"
        end
      end
    end
  end
  def set_rotten_tomatoes_score
    uri = URI.parse("https://www.rottentomatoes.com/api/private/v2.0/search/?limit=5&q=#{URI.escape(@original_title)}")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = https.request(request)
    result = JSON.parse(response.body)
    min_time_difference = 100
    result['movies'].each do |item|
      if item['meterScore'] != nil
        time_difference = (item['year'] - @year.to_i).abs
        if time_difference < min_time_difference
          min_time_difference = time_difference
          @rotten_tomatoes_score = "🍅 #{item['meterScore']}"
        end
      end
    end
  end
  def parse_filmweb_data
    uri = URI.parse(@filmweb_link)
    response = Net::HTTP.get_response(uri).body
    parsed_response = Nokogiri::HTML(response)

    filmweb_score = parsed_response.css('span.rateBox__rate').text
    @filmweb_score = "⭐ #{filmweb_score}" if filmweb_score.length != 0
    @original_title = parsed_response.css('div.filmPreview__originalTitle').text
    @original_title = @title if @original_title.length == 0
    
    cinemas = parsed_response.css('ul.film-cinemas').css('ul.film-cinemas').xpath("li")
    @hours = {}
    cinemas.each do |cinema|
      name = cinema.xpath("h3").text
      variants = {}
      cinema.xpath("div/div").each do |variant|
        variants[variant.xpath("div").text] = []
        variant.xpath("ul/li").each do |item|
          variants[variant.xpath("div").text] << item.text
        end
      end
      @hours[name] = variants
    end
  end
  private :set_year, :set_metacritic_score, :set_rotten_tomatoes_score, :parse_filmweb_data
end
