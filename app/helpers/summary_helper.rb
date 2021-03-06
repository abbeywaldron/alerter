module SummaryHelper

  def display_alert(alert)
    css_class = "active_#{alert.active}"
    "<p class=\"#{css_class}\"> #{alert.print} </p>".html_safe
  end


  def display_text(string)
    string.split("~*~").inject(""){ |str, n| str + "<p>#{n}</p>".html_safe}.html_safe
  end

end
