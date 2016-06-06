module ApplicationHelper


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


  def get_map_id
    id_path = ENV['OPENSHIFT_DATA_DIR'] + "/.MAP_ID"
    File.open(id_path).first.gsub("'","")
  end

  def get_map_token
    token_path = ENV['OPENSHIFT_DATA_DIR'] + "/.MAP_TOKEN"
    File.open(token_path).first.gsub("'","")
  end

  def get_emails
    mail_path = ENV['OPENSHIFT_DATA_DIR'] + "/.EMAILS"
    mails = Array.new
    File.open(mail_path).each do |line|
      email = line.match(/\w+@\w+/)
      mails << email[0] if email[0]
    end
    p mails
    mails
  end

end
