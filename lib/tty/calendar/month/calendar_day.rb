# frozen_string_literal: true
module TTY
  class Calendar
    class Month
      class CalendarDay
        attr_reader :date

        def initialize(date)
          @date = date
        end

        def render
          as_string = date.day.to_s
          as_string = " #{as_string}" if as_string.length == 1
          as_string
        end

        alias to_s render

      end

      class NullDay < CalendarDay
        def initialize; end

        def render
          '  '
        end
        alias to_s render
      end
    end
  end
end
