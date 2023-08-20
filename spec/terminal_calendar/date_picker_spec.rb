# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe TerminalCalendar::DatePicker do
  context 'when initialized with a month' do
    subject(:selector) { described_class.new(month, input: input, output: output) }

    let(:month) { TerminalCalendar::Month.new(6, 2023) }
    let(:today) { Date.new(2023, 1, 1) }
    let(:select_key) { "\t" }
    let(:quit_key) { "\r" }
    let(:input) { MockStringIO.new }
    let(:output) { MockStringIO.new }
    let(:left_direction) { "\e[D"  }
    let(:up_direction) { "\e[A" }

    before { Timecop.freeze(today) }
    after { Timecop.return  }

    describe '#pick' do
      subject(:pick) { selector.pick }

      let(:direction) { up_direction }

      before do
        input << quit_key
        input.rewind
      end

      # rubocop:disable RSpec/ExampleLength
      it 'prints the month' do
        cal_output = <<~CAL
               June 2023
          Su Mo Tu We Th Fr Sa
                       1  2  3
           4  5  6  7  8  9 10
          11 12 13 14 15 16 17
          18 19 20 21 22 23 24
          25 26 27 28 29 30#{'   '}
        CAL

        # wrapping to hide and show the cursor
        wrapped = "\e[?25l#{cal_output.chomp}\e[?25h"

        pick

        expect(output.string).to eq(wrapped)
      end
      # rubocop:enable RSpec/ExampleLength

      describe 'trying to toggle a day selector when one is not selected' do
        before do
          input << select_key << quit_key
          input.rewind
        end

        it { is_expected.to be_empty }
      end

      describe 'first move' do
        before do
          input << direction << quit_key
          input.rewind
        end

        let(:selected_day) do
          x = selector.selector.x
          y = selector.selector.y
          month.as_rows[y][x].day
        end

        context 'when the direction is up' do
          it 'sets the selector position to the last day of the month' do
            pick
            expect(selected_day).to eq 30
          end
        end

        context 'when the direction is left' do
          let(:direction) { left_direction }

          it 'sets the selector position to the last day of the month' do
            pick
            expect(selected_day).to eq 30
          end
        end

        context 'when the direction is down' do
          let(:direction) { "\e[B" }

          it 'sets the selector position to the first day of the month' do
            pick
            expect(selected_day).to eq 1
          end
        end

        context 'when the direction is right' do
          let(:direction) { "\e[C" }

          it 'sets the selector position to the first day of the month' do
            pick
            expect(selected_day).to eq 1
          end
        end
      end

      describe 'selecting a day' do
        before do
          input << up_direction << select_key << quit_key
          input.rewind
        end

        it 'returns the selected day in an array' do
          expect(pick).to eq [Date.new(2023, 6, 30)]
        end
      end

      describe 'selecting multiple days' do
        before do
          input << up_direction << select_key << left_direction << select_key << quit_key
          input.rewind
        end

        it 'returns the selected days in an array' do
          expect(pick).to eq [Date.new(2023, 6, 29), Date.new(2023, 6, 30)]
        end
      end
    end

    describe '#selection_grid' do
      subject { selector.selection_grid }

      it { is_expected.to be_a TerminalCalendar::Selection::Grid }
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
