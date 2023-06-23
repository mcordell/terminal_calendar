# frozen_string_literal: true

RSpec.describe TTY::Calendar::Month do
  describe '#render' do
    let(:month) {  described_class.new(3, 2023) }

    context 'when the month contains today' do
      before { Timecop.freeze(Date.new(2023, 6, 7)) }
      after { Timecop.return }

      let(:month) {  described_class.new(6, 2023) }

      it 'highlights the current day' do
        current_day = "\e[7m\e[31m 7\e[0m\e[0m"

        cal_output = <<~CAL
               June 2023
          Su Mo Tu We Th Fr Sa
                       1  2  3
           4  5  6 #{current_day}  8  9 10
          11 12 13 14 15 16 17
          18 19 20 21 22 23 24
          25 26 27 28 29 30#{'   '}
        CAL

        expect(month.render).to eq(cal_output.chomp)
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

        expect(month.render).to eq(cal_output.chomp)
      end

      context 'month with even letters' do
        let(:month) {  described_class.new(6, 2023) }

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

          expect(month.render).to eq(cal_output.chomp)
        end
      end

      context 'month with several empty days on final row' do
        let(:month) {  described_class.new(5, 2023) }

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

          expect(month.render).to eq(cal_output.chomp)
        end
      end
    end
  end
end
