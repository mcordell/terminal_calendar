# frozen_string_literal: true

# rubocop:disable RSpec/ExampleLength
RSpec.describe TerminalCalendar::Selection::MonthPage do
  subject(:instance) { described_class.new(month, pastel) }

  before { Timecop.freeze(Date.new(2023, 6, 7)) }
  after { Timecop.return }

  let(:pastel) { Pastel.new(enabled: true) }

  let(:month) {  TerminalCalendar::Month.new(3, 2023) }

  describe '#render' do
    subject(:rendered_output) { instance.render }

    context 'when the month contains today' do
      let(:month) {  TerminalCalendar::Month.new(6, 2023) }
      let(:current_day) { pastel.red(' 7') }

      it 'highlights the current day' do
        cal_output = <<~CAL
               June 2023
          Su Mo Tu We Th Fr Sa
                       1  2  3
           4  5  6 #{current_day}  8  9 10
          11 12 13 14 15 16 17
          18 19 20 21 22 23 24
          25 26 27 28 29 30#{'   '}
        CAL

        expect(rendered_output).to eq(cal_output.chomp)
      end

      it '#selection_grid_lines' do
        all_lines = instance.selection_grid_lines
        expect(all_lines[1]).to eq " 4  5  6 #{current_day}  8  9 10"
      end
    end

    context 'when month does not contain today' do
      before { Timecop.freeze(Date.new(2022, 12, 31)) }
      after { Timecop.return }

      it 'outputs a string for a month similar to "cal"' do
        cal_output = <<~CAL
               March 2023
          Su Mo Tu We Th Fr Sa
                    1  2  3  4
           5  6  7  8  9 10 11
          12 13 14 15 16 17 18
          19 20 21 22 23 24 25
          26 27 28 29 30 31#{'   '}
        CAL

        expect(rendered_output).to eq(cal_output.chomp)
      end

      context 'with a month with even letters' do
        let(:month) {  TerminalCalendar::Month.new(6, 2023) }

        it 'outputs a string for a month similar to "cal"' do
          cal_output = <<~CAL
                 June 2023
            Su Mo Tu We Th Fr Sa
                         1  2  3
             4  5  6  7  8  9 10
            11 12 13 14 15 16 17
            18 19 20 21 22 23 24
            25 26 27 28 29 30#{'   '}
          CAL

          expect(rendered_output).to eq(cal_output.chomp)
        end
      end

      context 'with a month with several empty days on final row' do
        let(:month) {  TerminalCalendar::Month.new(5, 2023) }

        it 'outputs a string for a month similar to "cal"' do
          cal_output = <<~CAL
                  May 2023
            Su Mo Tu We Th Fr Sa
                1  2  3  4  5  6
             7  8  9 10 11 12 13
            14 15 16 17 18 19 20
            21 22 23 24 25 26 27
            28 29 30 31#{'   ' * 3}
          CAL

          expect(rendered_output).to eq(cal_output.chomp)
        end
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength
