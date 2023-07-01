# frozen_string_literal: true
# rubocop:disable Naming::MethodParameterName
module TTY
  class Calendar
    module Selection
      class Selector
        extend Forwardable

        attr_accessor(:x, :y, :redraw_position)

        attr_reader(:selection_grid)

        def_delegators :selection_grid, :bottom_of_grid, :top_of_grid, :row_end

        def self.build(selection_grid, initial_spot)
          if initial_spot == :bottom
            x, y = selection_grid.bottom_right_live_cell_position
          else
            x, y = selection_grid.top_left_live_cell_position
          end

          new(x, y, selection_grid)
        end

        def initialize(x, y, selection_grid)
          @x = x
          @y = y
          @selection_grid = selection_grid
          @top_of_grid = 0
          @redraw_position = y
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
            if x == row_end
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

        def wrap(direction)
          case direction
          when :up
            @redraw_position = 0
            self.y = bottom_of_grid
          when :down
            self.y = top_of_grid
          when :left
            self.x = row_end
          when :right
            self.x = leftmost_gridsquare
          end
        end
      end
    end
  end
end
# rubocop:enable Naming::MethodParameterName
