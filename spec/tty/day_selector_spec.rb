# frozen_string_literal: true

module TTY
  class Calendar
    RSpec.describe DaySelector do
      context 'when initialized with a month' do
        let(:month) { Month.new(6, 2023) }
        let(:input) { StringIO.new }
        let(:output) { StringIO.new }
        subject(:selector) { described_class.new(month, input: input, output: output) }
        let(:today) { Date.new(2023, 1, 1) }
        before { Timecop.freeze(today) }
        after { Timecop.return  }

        describe '#select' do
          subject { selector.select }
          it 'prints the month' do
            input << 'q'
            input.rewind
            cal_output = <<~CAL
                   June 2023
              Su Mo Tu We Th Fr Sa
                           1  2  3
               4  5  6  7  8  9 10
              11 12 13 14 15 16 17
              18 19 20 21 22 23 24
              25 26 27 28 29 30#{'   '}
            CAL

            subject

            expect(output.string).to eq(cal_output)
          end

          let(:direction) { "\e[A" }
          subject { selector.select }

          describe 'first move' do
            let(:key_map) { TTY::Reader::Keys.keys.invert }

            before do
              input << direction << 'q'
              input.rewind
            end

            it 'initializes the selector' do
              expect do
                subject
              end.to change {
                       selector.instance_variable_get('@selector')
                     }.from(nil).to(be_a described_class::Selector)
            end

            context 'when the direction is up' do
              it 'sets the selector position to the last day of the month' do
                subject
                x, y = selector.selector.position
                expect(month.as_rows[x][y].day).to eq 30
              end
            end

            context 'when the direction is left' do
              let(:direction) { "\e[D" }

              it 'sets the selector position to the last day of the month' do
                subject
                x, y = selector.selector.position
                expect(month.as_rows[x][y].day).to eq 30
              end
            end

            context 'when the direction is down' do
              let(:direction) { "\e[B" }

              it 'sets the selector position to the first day of the month' do
                subject
                x, y = selector.selector.position
                expect(month.as_rows[x][y].day).to eq 1
              end
            end

            context 'when the direction is right' do
              let(:direction) { "\e[C" }

              it 'sets the selector position to the first day of the month' do
                subject
                x, y = selector.selector.position
                expect(month.as_rows[x][y].day).to eq 1
              end
            end
          end
        end

        describe '#selection_grid' do
          subject { selector.selection_grid }

          it 'contains SelectionCells' do
            expect(subject.flatten).to all be_a described_class::SelectionCell
          end

          it 'contains a row for each week in the month' do
            expect(subject.length).to eq 5
          end

          it 'each row has 7 cells, one for each days of the week' do
            expect(subject.map(&:length)).to all be 7
          end
        end
      end
    end
  end
end
