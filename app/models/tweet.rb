class Tweet < ActiveRecord::Base

  attr_accessor :text
  attr_accessor :time
  attr_accessor :username
  attr_accessor :location


  def set(tag)
    @text = tag['text']
    @username = tag['source']['username']
    @location = ( tag['locations'].size == 0 ) ? false : true
    @time = tag['date']
    @retweet = tag['retweet']
  end

  def is_retweet
    @retweet
  end


  def match(twits) # pass in array of all tweets for matching
    match_found = 0
    words = @text.downcase.gsub(/[^\p{Alnum}\p{Space}]/,"").split(" ").uniq
    twits.each do |twit|
      reference_words = twit.text.downcase.gsub(/[^\p{Alnum}\p{Space}]/,"").split(" ").uniq
      dups = words.inject(0){ |count, w| count += (reference_words.include?(w)) ? 1 : 0 }
      match_found += 1 if dups > 3
    end
    match_found
  end

  def css_class
    ( @location  ) ? "location" : "regular"
  end

end
