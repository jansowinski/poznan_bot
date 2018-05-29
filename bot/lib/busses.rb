require 'net/https'
require 'time'
require 'json'
require 'open-uri'


class TimeTable

  attr_reader :from_coordinates, :update

  def initialize
    @bus_stops = get_bus_stops
  end

  def from_coordinates(lng, lat)
    message = []
    find_closest_stops(lng, lat, 4).each do |stop|
      message << print_timetable(stop)
    end
    return message.join("\n\n")
  end

  def update
    @bus_stops = get_bus_stops
  end

  def print_timetable(bus_stop)
    array_to_ptint = ["🚏 Przystanek *#{@bus_stops[bus_stop]['name']}*\n"]
    get_timatable(bus_stop).each do |bus|
      emoticon = bus['line'].to_i < 30 ? "🚋" : "🚌"
      array_to_ptint << "#{emoticon}  #{bus['line']} - #{bus['minutes']} min. (→ #{bus['direction']})"
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
    if !response.body.include?('success')
      return ['Brak autobusów']
    end
    array = JSON.parse(response.body)['success']
    if array.include?('times')
      array = array['times']
    else
      array = array['bollard']['times']
    end
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

  def find_closest_stops(lng, lat, number_of_stops)
    differences_object = {}
    @bus_stops.each do |key, stop|
      lat_difference = lat - stop['coordinates']['lat']
      lng_difference = lng - stop['coordinates']['lng']
      differences_object[key] = Math.sqrt((lat_difference*lat_difference)+(lng_difference*lng_difference))
    end
    stops_by_distance = differences_object.sort_by{|key,value| value}
    return stops_by_distance[0..(number_of_stops - 1)].map{|array| array[0]}
  end
  
  private :print_timetable, :get_timatable, :get_bus_stops, :find_closest_stops
end
