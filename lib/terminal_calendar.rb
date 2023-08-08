# frozen_string_literal: true

require 'forwardable'
require_relative 'tty/prompt/carousel'
require_relative 'terminal_calendar/version'
require_relative 'terminal_calendar/month'
require_relative 'terminal_calendar/selection/cell'
require_relative 'terminal_calendar/selection/selector'
require_relative 'terminal_calendar/selection/grid'
require_relative 'terminal_calendar/selection/month_page'
require_relative 'terminal_calendar/selection/month_year_dialog'
require_relative 'terminal_calendar/date_picker'
require_relative 'date_extensions'
require 'pastel'
require 'tty-cursor'
require 'tty-reader'

class TerminalCalendar
  class Error < StandardError; end

  # This method allows the user to select one or more days starting from the current month calendar.
  #
  # @return [Array<Date>] The selected days.
  def self.date_picker
    TerminalCalendar::DatePicker.pick
  end

  # @param month [Month] month to render, defaults to the current month
  # @return [String] the month page as a string
  def self.cal(month=Month.this_month())
    Selection::MonthPage.build(month).render
  end

  # Stores a cache of month objects
  # @api private
  def self.all_months
    @all_months ||= {}
  end
end
