require 'net/https'
require 'time'
require 'json'
require 'open-uri'


class Timetable

  attr_reader :from_coordinates, :update

  def initialize
    @bus_stops = get_bus_stops
  end

  def from_coordinates(lng, lat)
    return print_timetable(find_closest_stop(lng, lat))
  end

  def update
    @bus_stops = get_bus_stops
  end

  def print_timetable(bus_stop)
    array_to_ptint = ["Przystanek #{@bus_stops[bus_stop]['name']}\n"]
    get_timatable(bus_stop).each do |bus|
      array_to_ptint << "#{bus['line']} - #{bus['minutes']} min. bus (#{bus['direction']})"
    end

    return array_to_ptint.join("\n")
  end

  def get_timatable(bus_stop)
    uri = URI.parse("https://www.peka.poznan.pl/vm/method.vm?ts=#{Time.now.to_i}")
    params = {
      :method => 'getTimes',
      :p0 => "{\"symbol\":#{bus_stop}}"
    }
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, initheader = {
      'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
      'User-Agent' => 'MetacriticUserscript Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0',
      'X-Requested-With' => 'XMLHttpRequest'
    })
    request.set_form_data(params)
    response = https.request(request)

    array = JSON.parse(response.body)['success']['times']
    bus_stop_name = JSON.parse(response.body)['success']['bollard']['name']

    array.each_with_index do |item, index|
      array[index]['busStop'] = bus_stop_name
    end

    return array.sort_by! {|time| time['minutes']}
  end

  def get_bus_stops
    uri = URI.parse('http://www.poznan.pl/mim/plan/map_service.html?mtype=pub_transport&co=cluster')
    response = Net::HTTP.get_response(uri)
    stops_array = JSON.parse(response.body)['features']
    stops_object = {}
    lon_array = []
    lat_array = []
    stops_array.each do |stop|
      stops_object[stop['id']] = {
        'name' => stop['properties']['stop_name'],
        'coordinates' => {
          'lat' => stop['geometry']['coordinates'][0],
          'lng' => stop['geometry']['coordinates'][1]
        },
        'lines' => stop['properties']['headsigns'].split(', ')
      }
    end
    return stops_object
  end

  def find_closest_stop(lng, lat)
    differences_object = {}
    @bus_stops.each do |key, stop|
      lat_difference = lat - stop['coordinates']['lat']
      lng_difference = lng - stop['coordinates']['lng']
      differences_object[key] = Math.sqrt((lat_difference*lat_difference)+(lng_difference*lng_difference))
    end
    return differences_object.min_by{|key,value| value}[0]
  end
  
  private :print_timetable, :get_timatable, :get_bus_stops, :find_closest_stop
end


table = Timetable.new
puts table.from_coordinates(52.469746, 16.953402)