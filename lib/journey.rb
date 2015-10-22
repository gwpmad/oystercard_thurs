require './lib/station'
require './lib/oystercard'

class Journey
attr_reader :entry
attr_accessor :exit

  def initialize(station)
    @entry = station
    @exit = nil
  end

  def in_journey?
    !exit
  end

  def fare
    (entry.zone - exit.zone).abs + Oystercard::MIN_BALANCE
  end

end
