# frozen_string_literal: true
require 'terminal_calendar/month/calendar_day'

class TerminalCalendar
  class Month
    # Returns an array of rows representing the data.
    # @return [Array<Array>] an array of arrays, where each inner array represents a row of data
    attr_reader :as_rows

    attr_reader :month, :year, :start_of_month, :end_of_month

    DAYS_IN_THE_WEEK = 7

    def self.this_month
      new(Date.today.month, Date.today.year)
    end

    def self.new(*arguments, &block)
      month = arguments[0].to_i
      fail ArgumentError.new('Month number must be 1-12') unless month >= 1 && month <= 12

      year = arguments[1].to_i
      key = [year, month]

      TerminalCalendar.all_months.fetch(key) do
        instance = allocate
        instance.send(:initialize, *arguments, &block)
        TerminalCalendar.all_months[key] = instance.freeze
      end
    end

    def initialize(month, year)
      @month = month.to_i
      @year = year.to_i
      @start_of_month = Date.new(year, month, 1)
      @end_of_month = @start_of_month.end_of_month
      @as_rows ||= build_rows
    end

    def next_month
      new_month = month == 12 ? 1 : month + 1
      new_year = new_month == 1 ? year + 1 : year
      self.class.new(new_month, new_year)
    end

    def previous_month
      new_month = month == 1 ? 12 : month - 1
      new_year = new_month == 12 ? year - 1 : year
      self.class.new(new_month, new_year)
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      other.month == month && other.year == year
    end

    def hash
      [month, year].hash
    end

    def render
      TerminalCalendar::Selection::MonthPage.new(self).render
    end

    private

    def build_rows
      current_row = empty_week
      [].tap do |rows|
        (start_of_month..end_of_month).each do |d|
          if d.wday.zero? && !current_row.empty?
            rows.push(current_row)
            current_row = empty_week
          end
          current_row[d.wday] = CalendarDay.new(d, pastel).freeze
        end
        rows.push(current_row) unless current_row.empty?
      end
    end

    def null_date
      @null_date ||= NullDay.new.freeze
    end

    def empty_week
      Array.new(DAYS_IN_THE_WEEK) { null_date }
    end

    def pastel
      @pastel ||= Pastel.new(enabled: true)
    end
  end
end
