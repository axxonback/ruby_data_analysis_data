# === COPYRIGHT:
#  Copyright (c) North Carolina State University
#  Developed with funding for the National eXtension Initiative.
# === LICENSE:
#  BSD(-compatible)
#  see LICENSE file

class YearWeekStats < Hash
  extend YearWeek

  def to_graph_data(hashvalue,options = {})
    showrolling = options[:showrolling].blank? ? true : options[:showrolling]
    returndata = []
    value_data = []
    rolling_data = []
    running_total = 0
    loopcount = 0
    self.yearweeks.each do |yearweek|
      loopcount += 1
      yearweek_date = self.class.yearweek_date(yearweek)
      value = self[yearweek][hashvalue] || 0
      value_data << [yearweek_date,value]
      if(showrolling)
        running_total += value
        rolling = running_total / loopcount
        rolling_data << [yearweek_date,rolling]
      end
    end

    if(showrolling)
      returndata = [value_data,rolling_data]
    else
      returndata = [value_data]
    end

    returndata
  end

  def max_for_hashvalue(hashvalue,nearest = nil)
    distribution = []
    self.yearweeks.each do |yearweek|
      if(!self[yearweek][hashvalue].nil?)
        distribution << self[yearweek][hashvalue]
      end
    end
    max = distribution.max
    if(nearest)
      max = max + nearest - (max % nearest)
    end
    max
  end

  def yearweeks
    if(!@yearweeks)
      @yearweeks = self.keys.reject{|keyname| keyname == :flags}.sort
    end
    @yearweeks
  end

  def flags
    if(self[:flags])
      self[:flags]
    else
      {}
    end
  end

  def to_percentile_graph_data(options = {})
    return [] if !flags[:percentiles]
    hashed_data = {}
    self.yearweeks.each do |yearweek|
      yearweek_date = self.class.yearweek_date(yearweek)
      hashed_data[:mean] ||= []
      hashed_data[:mean] << [yearweek_date,self[yearweek][:mean]]
      Settings.display_percentiles.each do |pct|
        hashed_data[pct] ||= []
        hashed_data[pct] << [yearweek_date,self[yearweek][pct]]
      end

    end
    hashed_data.values
  end

  def to_percentile_graph_labels(options = {})
    return [] if !flags[:percentiles]
    ['Average Views'] + Settings.display_percentiles_labels
  end

end