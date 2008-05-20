class Calendar
  include ViewHelpers

  # <tt>:month</tt> <Integer>:: the month for the calendar
  # <tt>:year</tt> <Integer>:: the year for the calendar
  # <tt>:days</tt> <Hash>:: the days for the calendar, including scheduled events
  attr_reader :month, :year, :days

  def initialize(options={})
    @month  = options[:month]  || Time.now.month
    @year   = options[:year]   || Time.now.year
    @events = options[:events] || []
    @page   = Time.utc(@year, @month)
    @days   = Hash.new

    days_in_month.times { |i| @days[i] = { :events => [] } }
  end

  alias_method :day, :days
  
  # The week day number the calendar starts on
  #
  # ==== Returns
  # Integer
  def starts_on
    @page.wday
  end
  
  def ends_on
    Time.utc(@page.year, @page.month, days_in_month).wday
  end
  
  def add(event_objects, options={})
    raise ArgumentError, "Must specify :schedule_for attribute to assign events to days." unless options[:schedule_for]
    options[:html_class] ||= options[:schedule_for]
    event_objects.each do |event|
      schedule_for = event.send(options[:schedule_for])
      if schedule_for && schedule_for.month == @page.month && schedule_for.year == @page.year
        @events << options[:html_class] unless @events.include?(options[:html_class])
        @days[schedule_for.day][:events] << options[:html_class]
      end
    end
  end
  
  def generate(options={})
    options[:header_length] ||= 1
    options[:ignore_today]  ||= false
    build options
  end
  
  # Borrowed from active_support
  def days_in_month
    if @page.month == 2
      !@page.year.nil? && (@page.year % 4 == 0) && ((@page.year % 100 != 0) || (@page.year % 400 == 0)) ?  29 : 28
    elsif @page.month <= 7
      @page.month % 2 == 0 ? 30 : 31
    else
      @page.month % 2 == 0 ? 31 : 30
    end
  end
  
end
