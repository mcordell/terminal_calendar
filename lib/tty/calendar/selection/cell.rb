# frozen_string_literal: true
module TTY
  class Calendar
    module Selection
      DEFAULT_SELECTED_STYLE = 'XX'

      class Cell
        # @return [Object] the object that this cell wraps
        attr_reader(:underlying_object)
        # @return [Boolean] whether this cell is currently selected
        attr_reader(:selected)
        # @return [String] the rendered style of a cell that is selected
        attr_reader(:selected_style)

        # Builds a new cell object based on the given object. If the
        # underlying object is Null, a NullCell will be returned
        # @param obj [Object] The object to build the cell from.
        # @return [Cell] The newly built cell object.
        def self.build(obj)
          obj.null? ? NullCell.new(obj) : new(obj)
        end

        def initialize(underlying_object, selected: false, selected_style: DEFAULT_SELECTED_STYLE)
          @underlying_object = underlying_object
          @selected = selected
          @selected_style = selected_style
        end

        # Renders the selected_style string if it is selected, otherwise
        # returns the result of rendering the underlying object.
        #
        # @return [String] The cell's rendered content
        def render
          return underlying_object.render unless selected?

          selected_style
        end

        # Checks if the object is null.
        #
        # @return [Boolean] Returns false.
        def null?
          false
        end

        # Toggles the selected state of the object.
        # @return [Boolean] the new selected state of the object
        def toggle_selected!
          @selected = !@selected
        end

        alias_method  :selected?, :selected

        # Calls the missing method on the underlying object.
        #
        # @param method [Symbol] the name of the missing method
        # @param args [Array] the arguments passed to the missing method
        # @param block [Proc] the block passed to the missing method
        # @return [Object] the result of calling the missing method on the underlying object
        # @raise [NoMethodError] if the underlying object does not respond to the missing method
        def method_missing(method, *args, &block)
          underlying_object.send(method, *args, &block)
        end

        # Checks if the underlying object responds to the missing method.
        #
        # @param method [Symbol] the name of the missing method
        # @param include_all [Boolean] whether to include private methods in the check
        # @return [Boolean] true if the underlying object responds to the missing method, super otherwise
        def respond_to_missing?(method, include_all)
          underlying_object.respond_to?(method) || super
        end
      end

      class NullCell < Cell
        def initialize
          super(nil)
        end

        def render
          '  '
        end

        # Checks if the object is null.
        #
        # @return [true] Returns true.
        def null?
          true
        end

        # @return [false] Returns false.
        def selected
          false
        end

        def toggle_selected!
          false
        end
      end
    end
  end
end
