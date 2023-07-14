# frozen_string_literal: true
require 'tty/calendar/month/calendar_day'

module TTY
  class Calendar
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

        TTY::Calendar.all_months.fetch(key) do
          instance = allocate
          instance.send(:initialize, *arguments, &block)
          TTY::Calendar.all_months[key] = instance.freeze
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
        TTY::Calendar::Selection::MonthPage.new(self).render
      end

      private

      def build_rows
        null_date = NullDay.new.freeze
        current_row = Array.new(DAYS_IN_THE_WEEK) { null_date }
        pastel = Pastel.new
        [].tap do |rows|
          (start_of_month..end_of_month).each do |d|
            if d.wday.zero? && !current_row.empty?
              rows.push(current_row)
              current_row = Array.new(DAYS_IN_THE_WEEK) { null_date }
            end
            current_row[d.wday] = CalendarDay.new(d, pastel).freeze
          end
          rows.push(current_row) unless current_row.empty?
        end
      end
    end
  end
end
