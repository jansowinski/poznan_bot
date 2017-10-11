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
      title = child.xpath("div[@class='filmBox']/div/div[@class='filmContent']/h3/a").text
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

class Movie
  attr_reader :movies, :get_movies_list

  def initialize
    @url = "http://www.filmweb.pl/showtimes/Pozna%C5%84"
    @movie_hash = {}
    get_movies_list
  end


  def movies
    string = ""
    @movie_hash.each do |key, value|
      next if key.length == 0
      string += "_#{key}_ #{value['ratings']['filmweb']} #{value['ratings']['metacritic']} #{value['ratings']['rotten_tomatoes']}\n"
    end
    return string
  end

  def seanses (argument)
    data = search(argument)
    return "" if data == nil
    ratings = @movie_hash[data[1]]['ratings']
    message = "*#{data[1].upcase}* #{ratings['filmweb'] + ratings['metacritic'] + ratings['rotten_tomatoes']}"
    data[0].each do |cinema, variants|
      message += "\n*#{cinema.gsub(' (Poznań)','')}*\n"
      variants.each do |variant, hours|
        dots = variant != "" ? ': ' : '' 
        message += variant + dots + hours.join(' ') + "\n"
      end
    end
    return message
  end

  def get_movies_list
    temp_movie_hash = {}
    uri = URI.parse(@url)
    response = Net::HTTP.get_response(uri).body
    movie_list = response.scan(/<li data-popularity(.+?)<\/li>/)
    movie_list.each do |item|
      item = item[0]
      name = /<a class=\"name.*\"> (.+?)<\/a><div/.match(item)[1]
      puts name
      link = /<a class=\"name.*href=\"(.+?)\"/.match(item)[1]
      puts link
      filmweb_rating = /space-left\">(.+?)</.match(item)[1]
      puts filmweb_rating
      link = "http://www.filmweb.pl#{link}"
      filmweb_rating = '⭐️' + (filmweb_rating.to_f * 10).to_i.to_s
      temp_movie_hash[name] = {
        "link" => link, 
        "ratings" => {
          "filmweb" => filmweb_rating,
          "rotten_tomatoes" => get_rotten_tomatoes_score(name),
          "metacritic" => get_metacritic_score(name)
        }
      }
    end
    @movie_hash = temp_movie_hash
    @movie_hash.keys
  end

  def get_original_title (searched_item)
    uri = URI.parse("http://www.filmweb.pl/search/live?q=#{URI.escape(searched_item)}")
    http = Net::HTTP.new(uri.host,uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    return response.body.gsub('\c', "\n").split("\n")[3]
  end


  def get_metacritic_score(searched_item)

    searched_item = get_original_title(searched_item)
    uri = URI.parse("http://www.metacritic.com/autosearch")
    http = Net::HTTP.new(uri.host,uri.port)
    request = Net::HTTP::Post.new(uri.path, initheader = {
      "Referer" => "http://www.metacritic.com/autosearch",
      "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
      "Host" => "www.metacritic.com",
      "User-Agent" => "MetacriticUserscript Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0",
      "X-Requested-With" => "XMLHttpRequest"
    })
    request.body = "search_term=#{URI.escape(searched_item)}&image_size=98&search_each=1&sort_type=popular"
    response = http.request(request)

    result = JSON.parse(response.body)

    result['autoComplete']['results'].each do |item|
      if item['metaScore'] != nil
        return "\u24C2 #{item['metaScore']}"
        break
      end
    end
    return ""
  end

  def get_rotten_tomatoes_score(searched_item)

    searched_item = get_original_title(searched_item)
    uri = URI.parse("https://www.rottentomatoes.com/api/private/v2.0/search/?limit=5&q=#{URI.escape(searched_item)}")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    https.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = https.request(request)
    
    result = JSON.parse(response.body)

    result['movies'].each do |item|
      if item['meterScore'] != nil
        return "🍅 #{item['meterScore']}"
        break
      end
    end
    return ""
  end

  def search (phrase)
    phrase.downcase!
    @movie_hash.each do |key, value|
      return hours(@movie_hash[key], key) if key.downcase.include?(phrase)
    end
    return nil
  end

  def hours (movie, title)
    uri = URI.parse(movie['link'])
    response = Net::HTTP.get_response(uri).body
    parsed_response = Nokogiri::HTML(response)
    cinemas = parsed_response.css('ul.film-cinemas').css('ul.film-cinemas').xpath("li")
    data = {}
    cinemas.each do |cinema|
      name = cinema.xpath("h3").text
      variants = {}
      cinema.xpath("div/div").each do |variant|
        variants[variant.xpath("div").text] = []
        variant.xpath("ul/li").each do |item|
          variants[variant.xpath("div").text] << item.text
        end
      end
      data[name] = variants
    end
    return [data, title]
  end

  private :search, :hours

end