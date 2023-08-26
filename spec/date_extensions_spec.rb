# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Date do
  describe '#beginning_of_month' do
    subject(:beginning_of_month) { described_class.new(2021, 9, 12).beginning_of_month }

    it 'returns the first day of that month' do
      expect(beginning_of_month).to eq described_class.new(2021, 9, 1)
    end
  end

  describe '#end_of_month' do
    subject(:end_of_month) { described_class.new(2024, 2, 21).end_of_month }

    context 'when the date is in feburary of a leap year' do
      it 'equals the 29th of Feb in that year' do
        expect(end_of_month).to eq described_class.new(2024, 2, 29)
      end
    end
  end
end
