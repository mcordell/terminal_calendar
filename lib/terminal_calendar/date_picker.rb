# frozen_string_literal: true

class TerminalCalendar
  class DatePicker
    extend Forwardable

    def self.pick(month: TerminalCalendar::Month.this_month)
      new(month).pick
    end

    attr_reader :month, :reader, :cursor

    # @return [TerminalCalendar::Selection::Selector]
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

      selection_loop

      month_pages.values.flat_map { |p| p.selection_grid.selected_cells.map(&:date) }
    ensure
      @output.print(@cursor.show)
    end

    def render
      @output.print(current_page.render)
    end

    private

    # rubocop:disable Metrics/MethodLength
    def selection_loop
      loop do
        press = reader.read_keypress
        kp = TTY::Reader::Keys.keys.fetch(press) { press }

        case kp
        when :up, :down, :left, :right
          move(kp)
          redraw
        when :tab
          toggle!
        when :return
          unless selector&.on_header?
            break
          end

          select_month
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def toggle!
      return if selector&.on_header?

      selector&.toggle_selected!
      redraw
    end

    def select_month
      clear_page_lines
      new_date = TerminalCalendar::Selection::MonthYearDialog.new(
        output: @output,
        start_at: current_page.month.start_of_month
      ).select
      new_month = TerminalCalendar::Month.new(new_date.month, new_date.year)
      set_new_page(new_month)
      clear_selection_dialog
      initialize_selector(:bottom)
      render
      @output.print(@cursor.hide)
      redraw
    end

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
    # @return [TerminalCalendar::Selection::Selector]
    def move(direction)
      return initialize_selector(direction) unless selector

      case selector.move(direction)
      when :off_left
        new_month = @current_page.month.previous_month
        set_new_page(new_month)
      when :off_right
        new_month = @current_page.month.next_month
        set_new_page(new_month)
      end
    end

    def set_new_page(new_month)
      clear_full_page!
      @current_page = month_pages.fetch(new_month) do
        month_pages[new_month] = Selection::MonthPage.build(new_month)
      end
      initialize_selector(:bottom)
      render
    end

    # Initializes the selector based on the given direction.
    #
    # @param direction [Symbol] The direction to initialize the selector.
    #   Must be one of :up, :left, :down, or :right.
    #
    # @return [TerminalCalendar::Selection::Selector]
    #
    # @api private
    def initialize_selector(direction)
      position = %i(up left).include?(direction) ? :bottom : :top
      @selector = TerminalCalendar::Selection::Selector.build(current_page, position)
    end
  end
end
