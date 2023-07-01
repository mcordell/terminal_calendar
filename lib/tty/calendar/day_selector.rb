# frozen_string_literal: true
#
module TTY
  class Calendar
    class DaySelector
      DAYS_IN_THE_WEEK = 7

      def self.select(month: TTY::Calendar::Month.this_month)
        new(month).select
      end

      attr_reader :month, :reader, :cursor

      def initialize(month, input: $stdin, output: $stdout, env: ENV, interrupt: :error,
                     track_history: true)
        @month = month
        @reader = TTY::Reader.new(
          input: input,
          output: output,
          interrupt: interrupt,
          track_history: track_history,
          env: env
        )
        @output = output
        @cursor = TTY::Cursor
        @pastel = Pastel.new
      end

      def select
        cursor.invisible do
          render

          loop do
            press = reader.read_keypress
            kp = TTY::Reader::Keys.keys.fetch(press) { press }

            case kp
            when :up, :down, :left, :right
              selection_grid.move(kp)
              redraw
            when :tab
              selection_grid.toggle_current_cell!
              redraw
            when :return
              @output.puts
              break
            end
          end
        end

        selection_grid.selected_cells.map(&:date)
      end

      def render
        @output.print(
          headers.concat(
            selection_grid.render_lines
          ).join("\n")
        )
      end

      def headers
        @month.calendar_header
      end

      def selection_grid
        @selection_grid ||= TTY::Calendar::Selection::Grid.build_from_objects(month.as_rows, pastel: @pastel)
      end

      private

      def redraw
        lines = selection_grid.redraw_lines
        @output.print(refresh(lines.length) + lines.join("\n"))
      end

      def refresh(lines)
        @cursor.clear_lines(lines)
      end
    end
  end
end
