# frozen_string_literal: true

module TTY
  class Calendar
    class DaySelector
      DAYS_IN_THE_WEEK = 7
      class Selector
        attr_accessor(:x, :y, :top_of_grid, :bottom_of_grid, :redraw_position)

        def self.build(selection_grid, initial_spot)
          y = 0
          case initial_spot
          when :bottom
            y = selection_grid.length - 1
            last_row = selection_grid[y]
            x = (last_row.length - 1).downto(0).find { |i| !last_row[i].null? }
          when :top
            x = (0..6).find { |i| !selection_grid[0][i].null? }
          else
            x = 0
          end

          new(x, y, selection_grid)
        end

        def initialize(grid_x, grid_y, selection_grid)
          @x = grid_x
          @y = grid_y
          @selection_grid = selection_grid
          @top_of_grid = 0
          @bottom_of_grid = selection_grid.length - 1
          @redraw_position = grid_y
        end

        def position
          [@y, @x]
        end

        %i(up down left right).each do |dir|
          define_method("move_#{dir}") { move(dir) }
        end

        def pre_move
          @redraw_position = nil
        end

        def post_move
          @redraw_position ||= y
        end

        def move(direction)
          pre_move
          case direction
          when :up
            if y == top_of_grid
              wrap(:up)
            else
              self.y -= 1
            end
          when :down
            if y == bottom_of_grid
              wrap(:down)
            else
              @redraw_position = self.y
              self.y += 1
            end
          when :left
            if x == leftmost_gridsquare
              wrap(:left)
            else
              self.x -= 1
            end
          when :right
            if x == rightmost_gridsquare
              wrap(:right)
            else
              self.x += 1
            end
          end

          post_move
        end

        def leftmost_gridsquare
          0
        end

        def rightmost_gridsquare
          DAYS_IN_THE_WEEK - 1
        end

        def wrap(direction)
          case direction
          when :up
            @redraw_position = 0
            self.y = bottom_of_grid
          when :down
            self.y = top_of_grid
          when :left
            self.x = rightmost_gridsquare
          when :right
            self.x = leftmost_gridsquare
          end
        end
      end

      class SelectionCell
        attr_reader(:calendar_day, :selected)

        def self.build(day_object)
          day_object.null? ? NullSelectionCell.new(day_object) : new(day_object)
        end

        def initialize(calendar_day, selected: false)
          @calendar_day = calendar_day
          @selected = selected
        end

        def render
          return calendar_day.render unless selected?

          'XX'
        end

        def null?
          false
        end

        def toggle_selected!
          @selected = !@selected
        end

        def date
          calendar_day.date
        end

        alias_method  :selected?, :selected
      end

      class NullSelectionCell < SelectionCell
        def null?
          true
        end

        def selected
          false
        end
      end

      attr_reader :month, :reader, :cursor, :selector

      def initialize(month, input: $stdin, output: $stdout, env: ENV, interrupt: :error, track_history: true)
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
          @output.puts(render)

          loop do
            press = reader.read_keypress
            kp = TTY::Reader::Keys.keys.fetch(press) { press }

            case kp
            when :up, :down, :left, :right
              if selector
                selector.move(kp)
              else
                initialize_selector(kp)
              end
              redraw_selector
            when 'x'
              toggle_selected
            when 'q'
              break
            end
          end
        end

        selection_grid.flatten.filter_map { |c| c.date if c.selected? }
      end

      def current_cell
        selection_grid[selector.y][selector.x]
      end

      def toggle_selected
        current_cell.toggle_selected!
        redraw_selector
      end

      def render
        month.calendar_header.concat(
          selection_grid.map do |row|
            row.map(&:render).join(' ')
          end
        ).join("\n")
      end

      def selection_grid
        @selection_grid ||= initialize_selection_grid
      end

      private

      def initialize_selection_grid
        month.as_rows.map do |row|
          row.map { |d| SelectionCell.build(d) }
        end
      end

      def redraw_selector
        rows = (selector.redraw_position..(selection_grid.length - 1)).map do |ri|
          next selection_grid[ri].map(&:render).join(' ') unless ri == selector.y

          (0..6).map do |x|
            rendered = selection_grid[ri][x].render
            next rendered unless x == selector.x

            @pastel.inverse(rendered)
          end.join(' ')
        end.join("\n")
        @output.puts(refresh((selection_grid.length - selector.redraw_position) + 1) + rows)
      end

      def refresh(lines)
        @cursor.clear_lines(lines)
      end

      def initialize_selector(direction)
        position = %i(up left).include?(direction) ? :bottom : :top
        @selector = Selector.build(selection_grid, position)
      end
    end
  end
end
