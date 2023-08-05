# frozen_string_literal: true

class TerminalCalendar
  RSpec.describe DatePicker do
    context 'when initialized with a month' do
      let(:month) { Month.new(6, 2023) }
      let(:input) { StringIO.new }
      let(:output) { StringIO.new }
      subject(:selector) { described_class.new(month, input: input, output: output) }
      let(:today) { Date.new(2023, 1, 1) }
      let(:select_key) { "\t" }
      let(:quit_key) { "\r" }
      before { Timecop.freeze(today) }
      after { Timecop.return  }

      describe '#pick' do
        subject { selector.pick }

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

          # wrapping to hide and show the cursor
          wrapped = "\e[?25l#{cal_output.chomp}\e[?25h"

          subject

          expect(output.string).to eq(wrapped)
        end

        let(:up_direction) { "\e[A" }
        let(:left_direction) { "\e[D"  }
        let(:direction) { up_direction }
        subject { selector.pick }

        describe 'trying to toggle a day selector does not have one selected' do
          before do
            input << select_key << quit_key
            input.rewind
          end

          it 'returns an empty array' do
            is_expected.to eq []
          end
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
              subject
              expect(selected_day).to eq 30
            end
          end

          context 'when the direction is left' do
            let(:direction) { left_direction }

            it 'sets the selector position to the last day of the month' do
              subject
              expect(selected_day).to eq 30
            end
          end

          context 'when the direction is down' do
            let(:direction) { "\e[B" }

            it 'sets the selector position to the first day of the month' do
              subject
              expect(selected_day).to eq 1
            end
          end

          context 'when the direction is right' do
            let(:direction) { "\e[C" }

            it 'sets the selector position to the first day of the month' do
              subject
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

        it { is_expected.to be_a TerminalCalendar::Selection::Grid }
      end
    end
  end

  RSpec.describe TerminalCalendar::Selection::Cell do
    let(:calendar_day) { instance_double(TerminalCalendar::Month::CalendarDay) }
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
