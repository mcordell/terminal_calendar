# frozen_string_literal: true

RSpec.describe TerminalCalendar do
  it 'has a version number' do
    expect(TerminalCalendar::VERSION).not_to be_nil
  end

  describe '.cal' do
    context 'when not passed a month' do
      subject { described_class.cal }

      before { Timecop.freeze(Date.new(2023, 6, 7)) }
      after { Timecop.return }

      it 'outputs month page for the current month' do
        current_day = "\e[31m 7\e[0m"

        cal_output = <<~CAL
               June 2023
          Su Mo Tu We Th Fr Sa
                       1  2  3
           4  5  6 #{current_day}  8  9 10
          11 12 13 14 15 16 17
          18 19 20 21 22 23 24
          25 26 27 28 29 30#{'   '}
        CAL

        expect(output).to eq(cal_output.chomp)
      end
    end
  end
end
