

# frozen_string_literal: true
class TerminalCalendar
  module Selection
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
