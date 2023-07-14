# frozen_string_literal: true

RSpec.describe TTY::Calendar::Month do
  before { Timecop.freeze(Date.new(2023, 6, 7)) }
  after { Timecop.return }
  subject(:instance) { described_class.new(6, 2023) }

  describe '.this_month' do
    subject(:instance) { described_class.this_month }

    it 'returns an instance initialized to the current month' do
      expect(instance.month).to eq 6
      expect(instance.year).to eq 2023
    end
  end

  describe '#render' do
    let(:month) {  described_class.new(3, 2023) }

    context 'when the month contains today' do
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

  describe '#==' do
    it 'is true for months with the same year and month' do
      month_one = described_class.new(5, 2023)
      month_two = described_class.new(5, 2023)
      expect(month_one == month_two).to eq true
    end
  end

  describe '#eql?' do
    it 'is true for months with the same year and month' do
      month_one = described_class.new(5, 2023)
      month_two = described_class.new(5, 2023)
      expect(month_one.eql?(month_two)).to eq true
    end
  end

  describe '#hash' do
    it 'has the same value for months with the same year and month' do
      month_one = described_class.new(5, 2023)
      month_two = described_class.new(5, 2023)
      expect(month_one.hash).to eq month_two.hash
    end
  end

  describe '#initialization' do
    it 'only returns one of the object' do
      month_one = described_class.new(3, 2023)
      month_two = described_class.new(3, 2023)
      expect(month_one.object_id).to eq month_two.object_id
    end
  end

  describe '#next_month' do
    let(:month) {  described_class.new(3, 2023) }
  end
end
