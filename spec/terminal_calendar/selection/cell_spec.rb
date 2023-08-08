# frozen_string_literal: true

RSpec.describe TerminalCalendar::Selection::Cell do
  subject(:cell) { described_class.new(calendar_day, selected: selected) }

  let(:calendar_day) { instance_double(TerminalCalendar::Month::CalendarDay) }
  let(:selected) { false }

  describe 'initialization' do
    context 'when initialized with a calendar day' do
      subject(:cell) { described_class.new(calendar_day) }

      it 'defaults to not selected' do
        expect(cell).not_to be_selected
      end

      context 'with a selected status' do
        subject(:cell) { described_class.new(calendar_day, selected: true) }

        it 'sets the selected status' do
          expect(cell).to be_selected
        end
      end
    end
  end

  describe '#render' do
    subject(:rendered_output) { cell.render }

    context 'when not selected' do
      it 'renders the calendar day' do
        calendar_day_render = '20'
        allow(calendar_day).to receive(:render).and_return(calendar_day_render)
        expect(rendered_output).to eq calendar_day_render
      end
    end

    context 'when selected' do
      let(:selected) { true }

      it "renders 'XX'" do
        expect(rendered_output).to eq 'XX'
      end
    end
  end

  describe '#date' do
    subject(:returned_date) { cell.date }

    let(:cal_day_date) { Object.new.freeze }

    it 'delegates to the calendar_day' do
      allow(calendar_day).to receive(:date).and_return(cal_day_date)
      expect(returned_date).to eq cal_day_date
    end
  end

  describe '#toggle_selected!' do
    context 'when not selected' do
      it 'sets the selected status to true' do
        expect { cell.toggle_selected! }.to change(cell, :selected?).from(false).to(true)
      end
    end

    context 'when selected' do
      let(:selected) { true }

      it 'sets the selected status to true' do
        expect { cell.toggle_selected! }.to change(cell, :selected?).from(true).to(false)
      end
    end
  end
end
