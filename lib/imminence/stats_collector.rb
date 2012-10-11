class Imminence::StatsCollector
  def self.statsd
    @statsd ||= Statsd.new("localhost").tap do |c|
      c.namespace = ENV['GOVUK_STATSD_PREFIX'].to_s
    end
  end

  def self.prefix_controller(name)
    if name.start_with?("admin/")
      return name.gsub("admin/", "admin.")
    end
    "api.#{name}"
  end

  def self.timing(time, controller, action)
    prefixed_controller = prefix_controller(controller)
    statsd.timing("response_time.#{prefixed_controller}.#{action}", time)
  end
end