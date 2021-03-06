class GraphData
  attr_accessor :data
  attr_accessor :errors
  attr_accessor :start_time
  attr_accessor :end_time

  def initialize
    @time_format1 = "%Y-%m-%dT%H:%M:%S.000Z"
    @time_format2 = "%Y/%m/%d %H:%M:%S"
  end

  def load(json)
    graph_data = Array.new
    json['values'].each do |val|
      graph_data << val[1]
    end
    @data = graph_data.inject(""){ |prev, e | prev + "#{e}," }
    @data[@data.size - 1] = ""
    @errors = graph_data.inject(""){ |prev, e | prev + "#{Math.sqrt(e).floor}," }
    @errors[@errors.size - 1] = ""
    @start_time = convert_time(json['meta']['requestParameters']['since'])
    @end_time = convert_time(json['meta']['requestParameters']['until'])
  end

  def convert_time(str)
    # format "YYYY/MM/DD HH:MM:SS"
    thing = DateTime.strptime(str,@time_format1)
    time_string = thing.strftime(@time_format2)
    time_string
  end
end

class OnMon < ActiveRecord::Base

  def get_json
    data = File.read("data/flood_data.json")
    JSON.parse(data)
  end


  def get_graph_data
    data = File.read("data/graph_data.json")
    json = JSON.parse(data)
    graph_data = GraphData.new
    graph_data.load(json)
    while (graph_data.data.split(",")).size < 144 # fill the rest of the day
      graph_data.data += ",0"
    end
    while( graph_data.errors.split(",")).size < 144
      graph_data.errors += ",0"
    end
    # need to change end time to be the end of the day?
    end_of_day = (graph_data.end_time.to_date).to_datetime + 1.days
    return graph_data.data, graph_data.errors, graph_data.start_time, end_of_day.strftime("%Y/%m/%d %H:%M:%S")
  end

  def get_trend_graph_data
    data = File.read("data/graph_data_trend.json")
    json = JSON.parse(data)
    graph_data = GraphData.new
    graph_data.load(json)
    while (graph_data.data.split(",")).size < 4*144 # fill the rest of the day
      graph_data.data += ",0"
    end
    while( graph_data.errors.split(",")).size < 4*144
      graph_data.errors += ",0"
    end
    # need to change end time to be the end of the day?
    end_of_day = (graph_data.end_time.to_date).to_datetime + 1.days
    return graph_data.data, graph_data.errors, graph_data.start_time, end_of_day.strftime("%Y/%m/%d %H:%M:%S")
  end


  def get_total
    json = self.get_json
    (json.nil? || json['meta'].nil?) ? 0 : json['meta']['total']
  end


  def get_end_time
    json = self.get_json
    return "" if ( json.nil? || json['meta'].nil? || json['meta']['requestParameters'].nil? )
    json['meta']['requestParameters']['until']
  end



  def get_tweets
    json = self.get_json
    return [] if json['tags'].nil?
    tweets = Array.new
    json['tags'].each do |tag|
      tweet = Tweet.new
      tweet.set(tag)
      tweets << tweet
    end
    tweets
  end


  def get_locations
    json = self.get_json
    return [] if json['tags'].nil?
    locations = Array.new
    location_coords = Hash.new
    json['tags'].each do |tag|
      next if tag['locations'].nil?
      next if tag['locations'].size == 0
      if tag['locations'].is_a?(Array) # case more than one location
        tag['locations'].each do |l|
          locations << l['name']
          coords = Array.new
          coords << l['loc']['lat']
          coords << l['loc']['lon']
          location_coords[l['name']] = coords
        end
      else # case one location
        locations << tag['locations']['name']
        coords = Array.new
        coords << tag['locations']['loc']['lat']
        coords << tag['locations']['loc']['lon']
        location_coords[tag['locations']['name']] = coords
      end
    end
    location_count = Hash.new(0)
    locations.each do |loc|
      location_count[loc] += 1
    end
    location_count.each do |place, count|
      location_coords[place] << count
    end
    # sort the location counts
    temp_loc_array = location_count.sort_by{ |k, v| -v }
    location_count = Hash.new(0)
    temp_loc_array.each do |k, v|
      location_count[k] = v
    end
    return location_count, location_coords
  end


  # maybe later display these as a tag cloud?  Font size increasing with numbe of times a word is mentioned?
  def get_keywords
    tweets = self.get_tweets
    counts = Hash.new(0)
    tweets.each do |tweet|
      tweet.text.downcase.split(/\s+/).each do |word|
        word.gsub!(/\p{^Alnum}/,'')
        next if word.size < 1
        counts[word] += 1
      end
    end
    temp_nest_array = (counts.select{ |k, v| v.to_i > 1}).sort_by{ |k, v| -v } # sort by count (descending) on counts of more than one word
    count_hash = Hash.new(0)
    temp_nest_array.each do |k, v|
      count_hash[k] = v
    end
    count_hash
  end


end
