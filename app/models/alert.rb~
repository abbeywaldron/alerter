class Alert < ActiveRecord::Base
  # don't make accessors...
  @@max_alerts = 2

  def self.find_latest
    # add a where clause on 'active' ?
    order('issued_at DESC').limit(1).first
  end



  def self.find_all
    output = ""
    alerts = order('issued_at DESC').limit(50).all
    #alerts = order('issued_at DESC').where(:active => true).limit(5)
    #    alerts.each do |a|
    #     output += "<p>" + a.print + "</p>"
    #   end
    #  output.html_safe
    alerts
  end


  def self.find_true
    output = ""
    alerts = order('issued_at DESC').where(:active => true).limit(5)
    alerts.each do |a|
      output += "<p>" + a.print + "</p>"
    end
    output.html_safe
  end


  def self.reject(tag_list)
    tweets = tag_list.size
    users = Array.new
    tag_list.each do |tl|
      matches = tl.match(tag_list)
      users << tl.username
      if matches > 0.5*tweets
        p "REJECTING, REPITITION, count = #{matches} out of #{tweets}"
        #return true # ALLOW NEWS FOR NOW
      end
    end
    user_list = users.inject(Hash.new(0)){|h, e| h[e] += 1; h}.sort_by{ |k,v| -v}.inject(Hash.new(0)){|h,pair| h[pair[0]] = pair[1]; h}
    # p user_list
    if user_list.values.first > 0.5*tweets
      p "Rejecting, suspicious user"
      return true
    end
    false
  end

  def self.active_count(offset=0)
    alerts = order('issued_at DESC').all
    sequence = Array.new
    tag_sequence = Array.new
    alerts.each do |a|
      sequence << a.active
      tag_sequence << a.tags
    end
    for i in 0...offset
      sequence.delete_at(i)
      tag_sequence.delete_at(i)
    end
    count = 0
    sequence.each do |thing|
      break unless thing
      count += 1
    end
    count
  end

  def self.issue(issued_at,tags,description,tag_list)


    latest = Alert.find_latest

    return false if Alert.reject(tag_list)


    ac = Alert.active_count
    ac1 = Alert.active_count(1)
    if latest.active
      if ac > @@max_alerts
        return false if ac > @@max_alerts+1
        Alert.issue_hold(issued_at,tags,description)
        p "skipping"
        # skip after @@max_alerts alerts issued until event over
        return false
      else
        p "issueing alert!"
        # do the location checking here
        loc = Locator.new
        loc.get_json
        top_locations, map_locations = loc.find_matches(tag_list)
        Alert.issue_alert(issued_at,tags,description,top_locations)
      end
    else
      # flood not current, did one just end?
      if ac1 > @@max_alerts
        # issue summary for previous event
        p "issueing summary"
        Alert.issue_summary(issued_at,tags,description,ac1)
      else
        # else no flood event
        p "no flood"
        return false
      end
    end
  end


  def self.issue_alert(issued_at, tags, description, locations)
    mail = DefaultMailer.alert(issued_at,tags,description,locations)
    mail.deliver
  end

  def self.issue_hold(issued_at, tags, description)
    mail = DefaultMailer.hold_alert(issued_at,tags,description)
    mail.deliver
  end

  def self.issue_summary(issued_at, tags, description, buckets)
    mail = DefaultMailer.end_alert(issued_at,tags,description,buckets)
    mail.deliver
  end



  # ------------- instance methods --------------------

  def get_tweets
    tweets = Array.new
    all_text = self.description.split("\n")
    #all_text.scan(/\~\*\~(.+)\*user\*/).each do |text|
    all_text.each do |text|
      tweet = Tweet.new
      tweet.text = text
      tweets << tweet
    end
    tweets
  end

  def print
    "#{self.issued_at} #{self.tags} #{self.threshold} #{self.active} #{Alert.active_count} #{Alert.active_count(1)}"
  end


end
