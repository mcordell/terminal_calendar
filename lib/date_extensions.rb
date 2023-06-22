# frozen_string_literal: true
require 'date'

# Useful extensions copied from ActiveSupport::CoreExt
module DateExtensions
  COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

  module ClassMethods
    def days_in_month(month, year)
      if month == 2 && ::Date.gregorian_leap?(year)
        29
      else
        COMMON_YEAR_DAYS_IN_MONTH[month]
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def beginning_of_month
    self.class.new(
      year,
      month,
      1
    )
  end

  def end_of_month
    self.class.new(
      year,
      month,
      self.class.days_in_month(month, year)
    )
  end
end

Date.include(DateExtensions)
