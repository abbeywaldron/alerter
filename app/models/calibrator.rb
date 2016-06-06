class Calibrator < ActiveRecord::Base


  after_initialize :init_calib

  def init_calib
    @constant_map = Hash.new
    @mean_rates = Hash.new
    @CL_rates = Hash.new
    File.open("data/calibration.txt","r").each do |line|
      hour, mean, cl, threshold = line.split(" ")
      @mean_rates[hour] = mean
      @CL_rates[hour] = cl
      @constant_map[hour] = threshold
    end
  end


  def threshold
    # get the current time in UTC
    hour = Time.now.utc
    # return the appropriate constant
    @constant_map[hour.hour.to_s].to_i
  end

  def means
    @mean_rates.values.join(",")
  end

  def cls
    @CL_rates.values.join(",")
  end


  def summary_data
    @mean_rates.values.join(",")
  end

end
