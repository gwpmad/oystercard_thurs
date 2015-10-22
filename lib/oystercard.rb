require './lib/station'

class Oystercard

  attr_reader :balance, :journeys, :journey_klass

  DEFAULT_BALANCE = 0
  BALANCE_LIMIT = 90
  MIN_BALANCE = 1
  PENALTY_FARE = 6

  def initialize(journey_klass,balance = DEFAULT_BALANCE)
    @balance = balance
    @journeys = []
    @journey_klass = journey_klass
  end

  def touch_in(station)
    fail "Insufficient funds, please top up #{MIN_BALANCE}" if insufficient_balance?
    deduct(PENALTY_FARE) if in_journey?
    @journey = journey_klass.new(station)
  end

  def touch_out(station)
    if in_journey?
      journey.exit = station
      deduct
    else
      deduct(PENALTY_FARE)
      return "penalty fare deducted"
    end
    # journey.exit = station
    # @journeys << @journey
    add_journeys(journey)
    @journey = nil
    journeys
  end

  def top_up(amount)
    fail "The limit is #{BALANCE_LIMIT}" if full?(amount)
    @balance += amount
  end

  def in_journey?
    !!journey
  end

private

  def full?(amount)
    @balance + amount > BALANCE_LIMIT
  end

  def insufficient_balance?
    @balance < MIN_BALANCE
  end

  def deduct(fare=journey.fare)
    @balance -= fare
  end

  def add_journeys journey
    @journeys << journey
  end

  attr_reader :journey

end
