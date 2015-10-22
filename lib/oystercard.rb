require './lib/station'

class Oystercard

  attr_reader :balance, :journeys, :journey_klass, :journey

  DEFAULT_BALANCE = 0
  BALANCE_LIMIT = 90
  MIN_BALANCE = 1
  PENALTY_FARE = 5

  def initialize(journey_klass,balance = DEFAULT_BALANCE)
    @balance = balance
    @journeys = []
    @station = nil
    @journey_klass = journey_klass
  end

  def touch_in(station)
    fail "Insufficient funds, please top up #{MIN_BALANCE}" if insufficient_balance?
    deduct(PENALTY_FARE) if in_journey?
    #@journey[:entry_station] = station
    @journey = journey_klass.new(station)
    @station = station
  end

  def touch_out(station)
    in_journey? ? deduct(MIN_BALANCE) : deduct(PENALTY_FARE)
    self.journey.exit = station
    @journeys << @journey
    @station = nil
  end

  def top_up(amount)
    fail "The limit is #{BALANCE_LIMIT}" if full?(amount)
    @balance += amount
  end

  def in_journey?
    @station == nil ? false : true
  end

private

  def full?(amount)
    @balance + amount > BALANCE_LIMIT
  end

  def insufficient_balance?
    @balance < MIN_BALANCE
  end

  def deduct(fare)
    @balance -= fare
  end

end
