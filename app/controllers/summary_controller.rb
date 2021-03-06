class SummaryController < ApplicationController

  def index
    latest = Alert.find_latest
    @latest = latest.print
    @all = Alert.find_all
  end

  def thing
    @current_alert = Alert.find(params[:id])
    @tweets = @current_alert.get_tweets
    loc = Locator.new
    loc.get_json # loads the location data
    @top_locations, @map_locations = loc.find_matches(@tweets)
  end


  def history
    @true_alerts = "" #Alert.find_true
  end

end
