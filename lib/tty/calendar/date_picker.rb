# frozen_string_literal: true
#
module TTY
  class Calendar
    class DatePicker
      extend Forwardable

      def self.pick(month: TTY::Calendar::Month.this_month)
        new(month).pick
      end

      attr_reader :month, :reader, :cursor

      # @return [TTY::Calendar::Selection::Selector]
      # @api private
      attr_reader :selector

      def initialize(month, input: $stdin, output: $stdout, env: ENV, interrupt: :error,
                     track_history: true)
        @current_page = Selection::MonthPage.build(month)
        @month_pages = [[month, @current_page]].to_h
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

      def pick
        @output.print(@cursor.hide)
        render

        loop do
          press = reader.read_keypress
          kp = TTY::Reader::Keys.keys.fetch(press) { press }

          case kp
          when :up, :down, :left, :right
            move(kp)
            redraw
          when :tab
            unless selector&.on_header?
              selector&.toggle_selected!
              redraw
            end
          when :return
            unless selector && selector&.on_header?
              break
            end

            clear_page_lines
            new_date = TTY::Calendar::Selection::MonthYearDialog.new(output: @output,
                                                                     start_at: current_page.month.start_of_month).select
            new_month = TTY::Calendar::Month.new(new_date.month, new_date.year)
            @current_page = month_pages.fetch(new_month) do
              month_pages[new_month] = Selection::MonthPage.build(new_month)
            end
            clear_selection_dialog
            initialize_selector(:bottom)
            render
            @output.print(@cursor.hide)
            redraw
          end
        end

        month_pages.values.flat_map { |p| p.selection_grid.selected_cells.map(&:date) }
      ensure
        @output.print(@cursor.show)
      end

      def render
        @output.print(current_page.render)
      end

      private

      def clear_full_page!
        @output.print(refresh(current_page.line_count))
      end

      def clear_page_lines
        @output.print(refresh(current_page.redraw_lines.length))
      end

      def clear_selection_dialog
        @output.print(refresh(2))
      end

      attr_reader :current_page, :month_pages

      def_delegators(:current_page, :selection_grid)

      def redraw
        lines = current_page.redraw_lines
        @output.print(refresh(lines.length) + lines.join("\n"))
      end

      def refresh(lines)
        @cursor.clear_lines(lines)
      end

      # Moves the selector in the specified direction.
      # @param direction [Symbol] The direction to move the selector in.
      #   Valid values are :up, :down, :left, and :right.
      #
      # @return [TTY::Calendar::Selection::Selector]
      def move(direction)
        return initialize_selector(direction) unless selector

        case selector.move(direction)
        when :off_left
          new_month = @current_page.month.previous_month
          clear_full_page!
          @current_page = month_pages.fetch(new_month) do
            month_pages[new_month] = Selection::MonthPage.build(new_month)
          end
          initialize_selector(:bottom)
          render
        when :off_right
          new_month = @current_page.month.next_month
          clear_full_page!
          @current_page = month_pages.fetch(new_month) do
            month_pages[new_month] = Selection::MonthPage.build(new_month)
          end
          initialize_selector(:bottom)
          render
        end
      end

      # Initializes the selector based on the given direction.
      #
      # @param direction [Symbol] The direction to initialize the selector.
      #   Must be one of :up, :left, :down, or :right.
      #
      # @return [TTY::Calendar::Selection::Selector]
      #
      # @api private
      def initialize_selector(direction)
        position = %i(up left).include?(direction) ? :bottom : :top
        @selector = TTY::Calendar::Selection::Selector.build(current_page, position)
      end
    end
  end
end
