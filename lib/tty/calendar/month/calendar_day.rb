# frozen_string_literal: true
module TTY
  class Calendar
    class Month
      class CalendarDay
        attr_reader :pastel, :date

        def initialize(date, pastel=Pastel.new)
          @date = date
          @pastel = pastel
        end

        def render
          as_string = day.to_s
          as_string = " #{as_string}" if as_string.length == 1
          as_string = pastel.inverse(pastel.red(as_string)) if today?
          as_string
        end

        alias to_s render

        def today?
          date == Date.today
        end

        def null?
          false
        end

        def day
          date.day
        end
      end

      class NullDay < CalendarDay
        def initialize; end

        def render
          '  '
        end
        alias to_s render

        def null?
          true
        end
      end
    end
  end
end
