require 'net/http'

class Request < ActiveRecord::Base

  @@time_format =  "%Y-%m-%dT%H:%M:%S.000Z"


  # method run by cron to update data file
  def self.fetch_data(interval,key,pswd)

    @@interval = interval
    @@api_key = key
    @@pswd = pswd
    Rails.application.configure do
      config.action_mailer.smtp_settings[:password] = pswd
    end

    # grab most recent data
    json = self.execute
    File.open("data/flood_data.json","w") do |f|
      f.write(JSON.generate(json))
    end


    # issue alert?
    self.issue_alert(json)


    # grab graph data (past day)
    graph_json = self.execute_graph(1)
    File.open("data/graph_data.json","w") do |f|
      f.write(JSON.generate(graph_json))
    end

    # grab graph data (past 3 and a bit days)
    # *** graph_json = self.execute_graph(4)
    File.open("data/graph_data_trend.json","w") do |f|
      f.write(JSON.generate(graph_json))
    end

  end


  def self.issue_alert(json)
    total = json['meta']['total']
    time = json['meta']['requestParameters']['until']
    tags = Array.new
    tag_list = Array.new
    json['tags'].each do |tag|
      tags << "#{tag['text']} *user* #{tag['source']['username']} "
      tweet = Tweet.new
      tweet.set(tag)
      tag_list << tweet
    end
    calibrator = Calibrator.new
    alert = Alert.new(issued_at: Time.now.utc, tags: total, threshold: calibrator.threshold, active: total > calibrator.threshold, description: tags)
    # alert = Alert.new(issued_at: Time.now.utc, tags: total, threshold: calibrator.threshold, active: true, description: tags)
    alert.save
    Alert.issue(time,total,tags,tag_list)
  end


  def self.execute
    end_time = DateTime.now.utc
    start_time = end_time - (@@interval).seconds
    startt = start_time.strftime(@@time_format)
    endt = end_time.strftime(@@time_format)

    tweet_parts = Array.new
    skip = 0

    while( true )
      options_string = "https://api.floodtags.com/v1/tags/indonesia/index"
      options_string += "?since=#{startt}&until=#{endt}"
      options_string += "&skip=#{skip}"
      options_string += "&omitRetweets=true"
      options_string += "&apiKey=" + "#{@@api_key}".html_safe
      response = self.call_api(options_string)
      json = JSON.parse(response)
      tweet_parts << json
      break if json['meta']['total'] <= skip + 50
      skip += 50
    end

    # join the parts
    output = tweet_parts[0]
    output['tags'] = tweet_parts.inject([]){ | last, e | last.concat(e['tags']) }
    output
  end

  def self.execute_graph(days)
    end_time = DateTime.now.utc
    start_time = (end_time.to_date).to_datetime # get start of day
    start_time -= (days-1).days # subtract and additional days

    graph_parts = Array.new

    # loop over times per 4 hours
    n_hours = 4
    lstart_time = start_time
    lend_time = [(start_time.to_time + n_hours.hours).to_datetime, end_time].min


    while( true )
      startt = lstart_time.strftime(@@time_format)
      endt = lend_time.strftime(@@time_format)
      options_string = "https://api.floodtags.com/v1/tags/indonesia/graph"
      options_string += "?since=#{startt}&until=#{endt}"
      options_string += "&interval=10m"
      options_string += "&omitRetweets=true"
      options_string += "&apiKey=" + "#{@@api_key}".html_safe
      response = self.call_api(options_string)
      graph_parts  << JSON.parse(response)
      break if lend_time >= end_time
      lstart_time = (lstart_time.to_time + n_hours.hours).to_datetime
      lend_time = [(lstart_time.to_time + n_hours.hours).to_datetime, end_time].min
    end

    # join the parts
    output = graph_parts[0]
    output['meta']['requestParameters']['until'] = graph_parts[graph_parts.size - 1]['meta']['requestParameters']['until']
    output['values'] = graph_parts.inject([]){ | last, e | last.concat(e['values']) }
    output
  end


  def self.call_api(options_string)
    uri = URI.parse(options_string)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.body
  end


end
