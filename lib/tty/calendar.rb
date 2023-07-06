# frozen_string_literal: true

require 'forwardable'
require_relative '../tty/prompt/carousel'
require_relative 'calendar/version'
require_relative 'calendar/month'
require_relative 'calendar/selection/cell'
require_relative 'calendar/selection/selector'
require_relative 'calendar/selection/grid'
require_relative 'calendar/day_selector'
require_relative '../date_extensions'
require 'pastel'
require 'tty-cursor'
require 'tty-reader'

module TTY
  class Calendar
    class Error < StandardError; end

    # This method allows the user to select one or more days from the current month calendar.
    #
    # @return [Date] The selected days.
    def self.select_days
      TTY::Calendar::DaySelector.select
    end
  end
end
