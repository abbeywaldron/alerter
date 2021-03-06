class Locator < ActiveRecord::Base

  attr_accessor :locations

  def get_json
    @locations = Hash.new
    data = File.read("data/region.geojson")
    json = JSON.parse(data)
    json['features'].each do |place|
      @locations[place['properties']['name']] = place['geometry']['coordinates'].reverse
    end
  end


  # put debugging output here...
  def find_matches(tweets)
    output = Array.new
    tweets.each do |tweet|
      matches = match(tweet)
      output.concat(matches) unless matches.length == 0
    end
    count_map = Hash.new(0)
    coord_map = Hash.new(0)
    output.each do |place|
      count_map[place] += 1
    end
    # order the count map here...
    count_map = count_map.sort_by{ |k,v| -v }.inject(Hash.new(0)){|h,pair| h[pair[0]] = pair[1]; h}
    count_map.each do |k, v|
      coord_map[k] = @locations[k].append(v)
    end
    return count_map, coord_map
  end

  def match(tweet)
    return [] if tweet.text.nil?
    matches = Array.new
    trials = @locations.keys
    trials.each do |trial|
      next if trial.nil?
      matches << trial if tweet.text.downcase.match(/#{trial.downcase}/)
    end
    matches
  end

end
