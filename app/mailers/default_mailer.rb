class DefaultMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  def alert(time, n_tags, tags, locations)
    endtime = DateTime.strptime(time,"%Y-%m-%dT%H:%M:%S.000Z")
    @time = endtime.strftime("%H:%M:%S (%d/%m/%Y)")
    @n_tags = n_tags
    @tags = tags
    @locations = locations
    @subject = "(#{@n_tags}) alert at #{@time} #{@locations.first}"
    @recipients = get_emails
    mail(to: @recipients, subject: @subject)
  end


  def hold_alert(time, n_tags, tags)
    endtime = DateTime.strptime(time,"%Y-%m-%dT%H:%M:%S.000Z")
    @time = endtime.strftime("%H:%M:%S (%d/%m/%Y)")
    @n_tags = n_tags
    @tags = tags
    @subject = "HOLDING ALERTS, EVENT ONGOING - #{@time}"
    @recipients = get_emails
    mail(to: @recipients, subject: @subject)
  end


  def end_alert(time, n_tags, tags, n_buckets)
    endtime = DateTime.strptime(time,"%Y-%m-%dT%H:%M:%S.000Z")
    @time = endtime.strftime("%H:%M:%S (%d/%m/%Y)")
    @n_tags = n_tags
    @tags = tags
    @n_buckets = n_buckets
    @subject = "End of alert (duration #{n_buckets}) at #{@time}"
    @recipients = get_emails
    mail(to: @recipients, subject: @subject)
  end

end
