# frozen_string_literal: true
# rubocop:disable Naming::MethodParameterName
module TTY
  class Calendar
    module Selection
      class Grid
        # @return [Array<Array>]
        # @api private
        attr_reader :grid

        attr_reader :highlighted_position

        # @return [Integer]
        # @api private
        attr_accessor :redraw_at

        # Builds a new grid from a array of arrays of objects
        #
        # @param [Array<Array>] objects The objects to build the grid from.
        # @param [Hash] opts
        #
        # @return [Grid]
        # @api public
        def self.build_from_objects(objects, _opts={})
          new(objects.first.length, objects.length).tap do |new_grid|
            new_grid.populate_from_objects(objects)
          end
        end

        # Initializes a new grid with the specified width and height.

        # @param width [Integer] the width of the grid
        # @param height [Integer] the height of the grid
        # @param pastel [Pastel] The pastel object to used for decorating text
        def initialize(width, height, pastel: Pastel.new)
          @grid = Array.new(height) do
            Array.new(width) { NullCell.new }
          end
          @pastel = pastel
        end

        # Builds a the grid from an array of arrays of objects
        #
        # @param [Array<Array>] objects the objects to populate the grid with
        # @return [Grid] self
        #
        # @api public
        def populate_from_objects(objects)
          objects.each_with_index do |object_row, y|
            object_row.each_with_index do |obj, x|
              populate_position(x, y, obj)
            end
          end
          self
        end

        # Populates a position on the grid with the given object.

        # @param x      [Integer] the x-coordinate of the position
        # @param y      [Integer] the y-coordinate of the position
        # @param object [Object] the object to wrap in the cell
        # @return       [Cell] the created cell
        def populate_position(x, y, object)
          return grid[y][x] if object.null?

          grid[y][x] = Cell.new(object)
        end

        # Returns the cell at the given coordinates.
        #
        # @param [Integer] x the x coordinate
        # @param [Integer] y the y coordinate
        # @return [Cell] the cell at the given coordinates
        #
        # @api public
        def cell(x, y)
          grid[y][x]
        end

        # Renders specified number of lines from the bottom of the grid as printable strings
        # @param count [Integer, Symbol] The number of lines to render. If set to :all, all lines will be rendered.
        # @return [Array<String>] An array of strings representing the rendered lines.
        def render_lines(count=:all)
          start_at = if count == :all || count > bottom_of_grid
                       0
                     else
                       bottom_of_grid - count
                     end

          highlighted_x, highlighted_y = highlighted_position

          (start_at..bottom_of_grid).map do |i|
            next grid[i].map(&:render).join(' ') unless highlighted_y && i == highlighted_y

            (0..row_end).map do |x|
              rendered = grid[i][x].render
              next rendered unless x == highlighted_x

              @pastel.inverse(rendered)
            end.join(' ')
          end
        end

        # Returns the y value of the bottom of the grid
        #
        # @return [Integer] the bottom of the grid
        #
        # @api public
        def bottom_of_grid
          grid.length - 1
        end

        # Returns the y value of the top of the grid
        #
        # @return [Integer] the top of the grid
        #
        # @api public
        def top_of_grid
          0
        end

        # Returns the bottom row of the grid
        #
        # @return [Array<TTY::Calendar::Selection::Cell>]
        #
        # @api public
        def bottom_row
          grid[bottom_of_grid]
        end

        # Returns the top row of the grid
        #
        # @return [Array<TTY::Calendar::Selection::Cell>]
        #
        # @api public
        def top_row
          grid[top_of_grid]
        end

        # Returns the first cell in the grid that is not null working from right to left, bottom to top.
        #
        # @return [Array<Integer>] the bottom right live cell position in the grid format x,y
        #
        # @example
        #   bottom_right_live_cell_position #=> [3, 3]
        #
        # @api public
        def bottom_right_live_cell_position
          bottom_of_grid.downto(top_of_grid).each do |y|
            row = grid[y]
            (row.length - 1).downto(0).each do |x|
              return [x, y] unless row[x].null?
            end
          end
        end

        # Returns the first cell in the grid that is not null working from left to right, top to bottom.
        #
        # @return [Array<Integer>] the top left live cell position in the grid format x, y
        #
        # @example
        #   top_left_live_cell_position #=> [2, 0]
        #
        # @api public
        def top_left_live_cell_position
          (top_of_grid..bottom_of_grid).each do |y|
            grid[y].each_with_index do |cell, x|
              return [x, y] unless cell.null?
            end
          end
        end

        # Returns all selected cells in the grid
        # @return [Array<Cell>] Selected cells
        def selected_cells
          grid.flatten.filter(&:selected?)
        end

        def redraw_lines
          render_lines(redraw_at.nil? ? :all : (grid.length - redraw_at))
        end

        def row_end
          grid.first.length - 1
        end

        def highlighted_position=(pos)
          @highlighted_position = pos
        end

        def clear_highlight!
          @highlighted_position = nil
        end

        def highlighted?
          @highlighted_position.nil?
        end
      end
    end
  end
end
# rubocop:enable Naming::MethodParameterName
