module TTY
  class Calendar
    module Selection
      class MonthPage
        WEEK_ROW = %w(Su Mo Tu We Th Fr Sa).freeze

        attr_reader :selection_grid, :month

        def self.build(month)
          new(month)
        end

        def initialize(month)
          @selection_grid = Grid.build_from_objects(month.as_rows)
          @month = month
          @pastel = Pastel.new
        end

        # Renders the calendar as a string.
        # @return [String] the rendered calendar as a string.
        def render
          render_rows.join("\n")
        end

        def redraw_lines
          if selection_grid.redraw_at.nil? || selection_grid.redraw_at.negative?
            calendar_header(selected: selection_grid&.redraw_at == -1).concat(selection_grid.redraw_lines)
          else
            selection_grid.redraw_lines
          end
        end

        def line_count
          @line_count ||= render_rows.count
        end

        private

        def render_rows
          calendar_header.concat(selection_grid.render_lines)
        end

        def refresh(lines)
          TTY::Cursor.clear_lines(lines)
        end

        def calendar_header(selected: false)
          week_row = WEEK_ROW.join(' ')
          month_row = month_header
          pad_size = (week_row.length - month_row.length) / 2
          month_row = @pastel.inverse(month_row) if selected
          month_row = (' ' * pad_size).concat(month_row)
          [
            month_row,
            week_row
          ]
        end

        def month_header
          Date::MONTHNAMES[@month.month] + " #{@month.year}"
        end
      end
    end
  end
end
