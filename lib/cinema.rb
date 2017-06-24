require 'time'
require 'net/http'
require 'uri'
require 'nokogiri'
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
            "palacoweUrl" => ["Nowe+Kino+Pa%C5%82acowe-1854", "Nowe Kino Pałacowe"],
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