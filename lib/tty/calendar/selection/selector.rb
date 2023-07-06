# frozen_string_literal: true
# rubocop:disable Naming::MethodParameterName
module TTY
  class Calendar
    module Selection
      class Selector
        extend Forwardable

        DIRECTIONS = %i(up down left right).freeze

        attr_reader(:x, :y, :selection_grid)

        def_delegators :selection_grid, :bottom_of_grid, :top_of_grid, :row_end

        def self.build(selection_grid, initial_spot)
          if initial_spot == :bottom
            x, y = selection_grid.bottom_right_live_cell_position
          else
            x, y = selection_grid.top_left_live_cell_position
          end

          new(x, y, selection_grid)
        end

        # Initializes a new selector
        #
        # @param x [Integer] the x-coordinate of the selector
        # @param y [Integer] the y-coordinate of the selector
        # @param selection_grid [Array<Array<TTY::Calendar::Selection::Cell>>] the selection grid
        # @param wrap [Symbol] (optional) the wrap direction, defaults to :all
        def initialize(x, y, selection_grid, wrap: :all)
          @x = x
          @selection_grid = selection_grid
          @top_of_grid = 0
          @y = y
          @wrap_directions = wrap
          post_move
        end

        # Toggles the selected state of the cell at the current position on the grid.
        #
        # @return [void]
        def toggle_selected!
          return unless on_grid?

          selection_grid.cell(@x, @y).toggle_selected!
        end

        # Determines if the selector is within the selection grid.
        #
        # @return [Boolean] Returns true if the point is within the selection grid, false otherwise.
        def on_grid?
          x >= leftmost_gridsquare && x <= selection_grid.row_end &&
            y >= selection_grid.top_of_grid && y <= selection_grid.bottom_of_grid
        end

        # Returns the leftmost grid square.
        #
        # @return [Integer] the leftmost grid square
        def leftmost_gridsquare
          0
        end

        # Moves the selector in the specified direction.
        #
        # @param direction [Symbol] The direction to move in.
        #   Valid directions are: :up, :down, :left, :right.
        # @raise [ArgumentError] if the specified direction is not valid.
        # @return [void]
        def move(direction)
          fail ArgumentError.new("Unknown direction #{direction}") unless DIRECTIONS.include?(direction)

          pre_move

          send("move_#{direction}")

          post_move
        end

        private

        attr_writer(:x, :y)

        def pre_move
          selection_grid.redraw_at = nil
          selection_grid.clear_highlight!
        end

        def post_move
          unless selection_grid.redraw_at
            selection_grid.redraw_at = y
          end
          return unless on_grid?

          selection_grid.highlighted_position = [x, y]
        end

        def wrap(direction)
          case direction
          when :up
            selection_grid.redraw_at = 0
            self.y = bottom_of_grid
          when :down
            self.y = top_of_grid
          when :left
            self.x = row_end
          when :right
            self.x = leftmost_gridsquare
          end
        end

        def move_up
          if y == top_of_grid
            wrap(:up)
          else
            self.y -= 1
          end
        end

        def move_down
          if y == bottom_of_grid
            wrap(:down)
          else
            selection_grid.redraw_at = y
            self.y += 1
          end
        end

        def move_left
          if x == leftmost_gridsquare
            wrap(:left)
          else
            self.x -= 1
          end
        end

        def move_right
          if x == row_end
            wrap(:right)
          else
            self.x += 1
          end
        end
      end
    end
  end
end
# rubocop:enable Naming::MethodParameterName
