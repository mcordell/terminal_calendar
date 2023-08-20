# frozen_string_literal: true
class TerminalCalendar
  module Selection
    class MonthYearDialog
      extend Forwardable

      # Initializes a new MonthYearDialog instance.
      #
      # @param start_at [Date] the starting date for the dialog (default: Date.today)
      # @param input [IO] the input stream to read user input from (default: $stdin)
      # @param output [IO] the output stream to write messages to (default: $stdout)
      # @param env [Hash] the environment variables (default: ENV)
      # @param interrupt [Symbol] the behavior when an interrupt signal is received (:error or :exit) (default: :error)
      # @param track_history [Boolean] whether to track user input history (default: true)
      # @return [MonthYearDialog] the initialized MonthYearDialog instance
      def initialize(input: $stdin, output: $stdout, env: ENV, interrupt: :error, track_history: true,
                     start_at: Date.today)
        @output = output
        @reader = TTY::Reader.new(
          input: input,
          output: output,
          interrupt: interrupt,
          track_history: track_history,
          env: env
        )
        initialize_carousels(start_at)
        @cursor = TTY::Cursor
      end

      # Renders the dialog for month and year to the output
      def render
        month_car.render
        @output.puts
        year_car.render
      end

      def select
        cursor.invisible do
          render

          key_capture
        end
      end

      def redraw(amt=2)
        @output.print(cursor.clear_lines(amt))
        amt == 2 ? render : year_car.render
      end

      def_delegator :@month_car, :selected_option, :selected_month
      def_delegator :@year_car, :selected_option, :selected_year

      private

      def key_capture
        loop do
          case get_key_press
          when :up, :down
            toggle_selected
            redraw(2)
          when :left
            selected_car.move_left
            redraw(@selected == :year ? 1 : 2)
          when :right
            selected_car.move_right
            redraw(@selected == :year ? 1 : 2)
          when :return
            return Date.new(selected_year.to_i, Date::MONTHNAMES.find_index(selected_month), 1)
          end
        end
      end

      def get_key_press
        press = reader.read_keypress
        TTY::Reader::Keys.keys.fetch(press) { press }
      end

      def initialize_carousels(start_at)
        @selected = :month
        @month_car = TTY::Prompt::Carousel.new(Date::MONTHNAMES.compact, start_at: start_at.month - 1,
                                                                         option_style: :inverse, output: output)
        @year_car = TTY::Prompt::Carousel.new((0..3000).map(&:to_s), start_at: start_at.year, output: output,
                                                                     margin: 0, padding: 4)
      end

      def selected_car
        @selected == :month ? month_car : year_car
      end

      attr_reader(:output, :month_car, :year_car, :cursor, :reader)

      def toggle_selected
        @selected = @selected == :month ? :year : :month
        month_car.option_style = @selected == :month ? :inverse : nil
        year_car.option_style = @selected == :year ? :inverse : nil
      end
    end
  end
end
