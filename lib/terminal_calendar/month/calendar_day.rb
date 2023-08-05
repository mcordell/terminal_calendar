# frozen_string_literal: true
class TerminalCalendar
  class Month
    class CalendarDay
      # @return [Pastel] The pastel object to use for decorating text
      attr_reader :pastel

      # @return [Date] The date for this calendar day
      attr_reader :date

      # @param date [Date] The date to be assigned to this calendar day
      # @param pastel [Pastel] The pastel object to use for decorating text
      def initialize(date, pastel=Pastel.new)
        @date = date
        @pastel = pastel
      end

      # Renders the day as a string.
      # @return [String] the day as a string
      def render
        as_string = day.to_s
        as_string = " #{as_string}" if as_string.length == 1
        as_string = pastel.red(as_string) if today?
        as_string
      end

      alias to_s render

      # Determines if the given date is today.
      #
      # @return [Boolean] Returns true if the date is today, false otherwise.
      def today?
        date == Date.today
      end

      # Returns whether the object is null or not.
      #
      # @return [false] Returns false.
      def null?
        false
      end

      # Returns the day of the date.
      #
      # @return [Integer] The day of the date.
      def day
        date.day
      end
    end

    class NullDay < CalendarDay
      def initialize
        super(nil)
      end

      def render
        '  '
      end
      alias to_s render

      # Returns whether the object is null or not.
      #
      # @return [true] Returns true.
      def null?
        true
      end
    end
  end
end
