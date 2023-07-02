# frozen_string_literal: true
require 'tty-prompt'

module TTY
  class Prompt
    class Carousel
      extend Forwardable
      attr_accessor :option_style

      DEFAULT_KEY_MAP = {
        left: :left,
        right: :right,
        end_keys: [:return]
      }.freeze

      def initialize(options, start_at: 0, key_map: DEFAULT_KEY_MAP, input: $stdin, output: $stdout, env: ENV, interrupt: :error,
                     track_history: true, option_style: nil)
        @reader = TTY::Reader.new(
          input: input,
          output: output,
          interrupt: interrupt,
          track_history: track_history,
          env: env
        )
        @key_map = DEFAULT_KEY_MAP.merge(key_map)
        @output = output
        @options = options
        @max_option_length = @options.map(&:length).max
        @padding = 2
        @content_size = @padding + @max_option_length + @padding
        @current_index = start_at
        @cursor = TTY::Cursor
        @pastel = Pastel.new
        @option_style = option_style
      end

      def select
        render
        loop do
          press = reader.read_keypress
          kp = TTY::Reader::Keys.keys.fetch(press) { press }
          case kp
          when key_map[:left]
            move_left
            redraw
          when key_map[:right]
            move_right
            redraw
          when *key_map[:end_keys]
            @output.puts
            break
          end
        end
      end

      def render
        output.print("#{left_arrow}#{content}#{right_arrow}")
      end

      def content
        padding = content_size - selected_option.length
        padding_left = padding / 2
        padding_right = padding - padding_left
        (' ' * padding_left) + style_option + (' ' * padding_right)
      end

      def move_left
        @current_index -= 1
        @current_index = @options.length - 1 if current_index.negative?
      end

      def move_right
        @current_index += 1
        @current_index = 0 if current_index >= options.length
      end

      def redraw
        output.print(clear_lines(1))
        render
      end

      def selected_option
        options[current_index]
      end

      private

      def left_arrow
        TTY::Prompt::Symbols::KEYS.fetch(:arrow_left)
      end

      def right_arrow
        TTY::Prompt::Symbols::KEYS.fetch(:arrow_right)
      end

      def style_option
        return selected_option unless option_style

        pastel.decorate(selected_option, *option_style)
      end

      attr_reader :reader, :key_map, :options, :pastel, :current_index, :output, :content_size

      def_delegator :@cursor, :clear_lines
    end
  end
end
