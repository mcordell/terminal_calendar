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
        let(:select_key) { 'x' }
        let(:quit_key) { 'q' }
        before { Timecop.freeze(today) }
        after { Timecop.return  }

        describe '#select' do
          subject { selector.select }
          it 'prints the month' do
            input << quit_key
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

          let(:up_direction) { "\e[A" }
          let(:left_direction) { "\e[D"  }
          let(:direction) { up_direction }
          subject { selector.select }

          describe 'first move' do
            let(:key_map) { TTY::Reader::Keys.keys.invert }

            before do
              input << direction << quit_key
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
              let(:direction) { left_direction }

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

          describe 'selecting a day' do
            before do
              input << up_direction << select_key << quit_key
              input.rewind
            end

            it 'returns the selected day in an array' do
              is_expected.to eq [Date.new(2023, 6, 30)]
            end
          end

          describe 'selecting multiple days' do
            before do
              input << up_direction << select_key << left_direction << select_key << quit_key
              input.rewind
            end

            it 'returns the selected days in an array' do
              is_expected.to eq [Date.new(2023, 6, 29), Date.new(2023, 6, 30)]
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

    RSpec.describe DaySelector::SelectionCell do
      let(:calendar_day) { instance_double(TTY::Calendar::Month::CalendarDay) }
      let(:selected) { false }
      subject(:cell) { described_class.new(calendar_day, selected: selected) }

      describe 'initialization' do
        context 'when initialized with a calendar day' do
          subject(:cell) { described_class.new(calendar_day) }

          it 'defaults to not selected' do
            is_expected.not_to be_selected
          end

          context 'and selected status' do
            it 'sets the selected status' do
              is_expected.not_to be_selected
            end
          end
        end
      end

      describe '#render' do
        subject { cell.render }
        context 'when not selected' do
          it 'renders the calendar day' do
            calendar_day_render = '20'
            allow(calendar_day).to receive(:render).and_return(calendar_day_render)
            is_expected.to eq calendar_day_render
          end
        end

        context 'when selected' do
          let(:selected) { true }
          it "renders 'XX'" do
            is_expected.to eq 'XX'
          end
        end
      end

      describe '#date' do
        let(:cal_day_date) { Object.new.freeze }

        subject { cell.date }
        it 'delegates to the calendar_day' do
          allow(calendar_day).to receive(:date).and_return(cal_day_date)
          is_expected.to eq cal_day_date
        end
      end

      describe '#toggle_selected!' do
        subject { cell.toggle_selected! }
        context 'when not selected' do
          it 'sets the selected status to true' do
            expect { subject }.to change(cell, :selected?).from(false).to(true)
          end
        end

        context 'when selected' do
          let(:selected) { true }

          it 'sets the selected status to true' do
            expect { subject }.to change(cell, :selected?).from(true).to(false)
          end
        end
      end
    end
  end
end
