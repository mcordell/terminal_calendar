# frozen_string_literal: true
require 'tty/calendar/month/calendar_day'

module TTY
  class Calendar
    class Month
      attr_reader :month, :year, :start_of_month, :end_of_month, :pastel

      WEEK_ROW = %w(Su Mo Tu We Th Fr Sa).freeze
      DAYS_IN_THE_WEEK = WEEK_ROW.length

      def self.this_month
        new(Date.today.month, Date.today.year)
      end

      def initialize(month, year)
        @month = month.to_i
        @year = year.to_i
        @start_of_month = Date.new(year, month, 1)
        @end_of_month = @start_of_month.end_of_month
        @pastel = Pastel.new
      end

      def render
        calendar_header.concat(
          as_rows.map do |row|
            row.map(&:to_s).join(' ')
          end
        ).join("\n")
      end
      alias to_s render

      def as_rows
        @as_rows ||= build_rows
      end

      def build_rows
        null_date = NullDay.new
        current_row = Array.new(7) { null_date }
        [].tap do |rows|
          (start_of_month..end_of_month).each do |d|
            if d.wday.zero? && !current_row.empty?
              rows.push(current_row)
              current_row = Array.new(7) { null_date }
            end
            current_row[d.wday] = CalendarDay.new(d, pastel)
          end
          rows.push(current_row) unless current_row.empty?
        end
      end

      def calendar_header
        week_row = WEEK_ROW.join(' ')
        month_row = month_header
        pad_size = (week_row.length - month_row.length) / 2
        month_row = (' ' * pad_size).concat(month_row)
        [
          month_row,
          week_row
        ]
      end

      def month_header
        Date::MONTHNAMES[month] + " #{year}"
      end
    end
  end
end
