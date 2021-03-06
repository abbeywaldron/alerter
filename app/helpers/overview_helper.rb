module OverviewHelper


  def display_tweet(tweet)
    body = "#{tweet.text} ---#{tweet.username} (#{tweet.time})".html_safe
    css_class = tweet.css_class.html_safe
    output = "<div class=\"row tweet_holder "
    output += css_class
    output += "\"><div class=\"col-xs-12\"><span class=\"single_tweet\">"
    output += auto_link(body, :html => { :target => 'top'} )
    output += "</span></div></div>"
    output.html_safe
  end


  def display_words(count_map)
    output = ""
    count_map.each do |k, v|
      output += "#{k}: #{v}<br>"
    end
    output.html_safe
  end



  def circle_radius(count)
    [count*20000, 200000].min
  end

  def circle_colour
    # "#ff7800"
    "red"
  end

  def circle_fill_colour
    # "#ff9700"
    "red"
  end


  def map_font(count, min_count, max_count)
    return 16 if min_count == max_count
    min_font, max_font = 16, 36
    place = (count - min_count).fdiv(max_count - min_count)
    (min_font + place*(max_font-min_font)).floor
  end

  def display_word_cloud(count_map)
    # work out the range of sizes
    min_count, max_count = count_map.values.minmax

    # map font sizes
    font_map = count_map.clone
    font_map.each do |k, v|
      font_map[k] = map_font(v, min_count, max_count)
    end

    # output some html
    output = ""
    font_map.each do |k, v|
      output += "<span style=\"font-size: #{v}px;\">#{k}(#{count_map[k]}) </span>"
    end
    output.html_safe
  end

end
