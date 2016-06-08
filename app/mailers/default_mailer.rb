class DefaultMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def self.get_emails
    mail_path = ENV['OPENSHIFT_DATA_DIR'] + "/.EMAILS"
    mails = Array.new
    File.open(mail_path).each do |line|
      email = line.match(/\w+@\w+\.\w+/)
      mails << email[0] if email[0]
    end
    p mails
    mails
  end


  def alert(time, n_tags, tags, locations)
    endtime = DateTime.strptime(time,"%Y-%m-%dT%H:%M:%S.000Z")
    @time = endtime.strftime("%H:%M:%S (%d/%m/%Y)")
    @n_tags = n_tags
    @tags = tags
    @locations = locations
    @subject = "(#{@n_tags}) alert at #{@time} #{@locations.first}"
    @recipients = DefaultMailer.get_emails
    mail(to: @recipients, subject: @subject)
  end


  def hold_alert(time, n_tags, tags)
    endtime = DateTime.strptime(time,"%Y-%m-%dT%H:%M:%S.000Z")
    @time = endtime.strftime("%H:%M:%S (%d/%m/%Y)")
    @n_tags = n_tags
    @tags = tags
    @subject = "HOLDING ALERTS, EVENT ONGOING - #{@time}"
    @recipients = DefaultMailer.get_emails
    mail(to: @recipients, subject: @subject)
  end


  def end_alert(time, n_tags, tags, n_buckets)
    endtime = DateTime.strptime(time,"%Y-%m-%dT%H:%M:%S.000Z")
    @time = endtime.strftime("%H:%M:%S (%d/%m/%Y)")
    @n_tags = n_tags
    @tags = tags
    @n_buckets = n_buckets
    @subject = "End of alert (duration #{n_buckets}) at #{@time}"
    @recipients = DefaultMailer.get_emails
    mail(to: @recipients, subject: @subject)
  end

end
