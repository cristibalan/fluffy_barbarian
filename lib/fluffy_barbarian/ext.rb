require 'active_support'
require 'active_support/inflector/transliterate'
require 'date'

module Enumerable
  def tidy
    self.find_all{ |e| e && e.tidy != "" }.map(&:tidy)
  end
end

class String
  def tidy
    self.chomp.strip.squeeze(" ")
  end

  # nicked form AS
  def parameterize(sep = '-')
    ActiveSupport::Inflector.parameterize(self, sep)
  end
end

class Date
  def to_s(style=nil)
    month_names = ['ianuarie', 'februarie', 'martie', 'aprilie', 'mai', 'iunie', 'iulie', 'august', 'septembrie', 'octombrie', 'noiembrie', 'decembrie']
    case style
    when :short
      "#{self.day} #{month_names[self.month-1]}"
    when :long
      "#{self.day} #{month_names[self.month-1]} #{self.year}"
    else
    end
  end
end
