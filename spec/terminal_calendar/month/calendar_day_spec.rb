# frozen_string_literal: true

RSpec.describe TerminalCalendar::Month::CalendarDay do
  let(:pastel) { Pastel.new(enabled: true) }
  let(:date) { Date.new(2023, 8, 1) }

  before { Timecop.freeze(Date.new(2023, 6, 7)) }
  after { Timecop.return }

  subject(:instance) { described_class.new(date, pastel) }

  describe 'Testing color' do
    it 'works like pastel' do
      expect(pastel.red('unicorn')).to eq("\e[31municorn\e[0m")
    end
  end

  describe '#render' do
    subject { instance.render }

    context 'when it is today' do
      let(:date) { Date.new(2023, 6, 7) }

      it 'is styled red' do
        is_expected.to eq("\e[31m 7\e[0m")
      end
    end
  end
end
