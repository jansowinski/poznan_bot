require 'time'
class Meteo
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
  def get
    url_adress = "http://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&fdate=" + date_setter + hour_num + "&row=400&col=180&lang=pl"
  return url_adress
  end
end