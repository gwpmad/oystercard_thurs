require 'oystercard'

describe Oystercard do
  let (:station) {double :station, name: "Aldgate", zone: 1}
  subject(:oystercard) {described_class.new(journey_klass)}
  let(:journey_klass) {double(:journey_klass)}
  double_fare = 1
  let(:journey) {double(:journey, :entry => :station, :exit => :station, :exit= => nil, :fare => double_fare)}

  before(:each) do
    allow(journey_klass).to receive(:new).with(station).and_return(journey)
  end

  it "has a balance of zero" do
    expect(subject.balance).to eq (0)
  end

  it 'records a journey' do
    expect(subject.journeys).to be_empty
  end

describe '#top_up' do
  it "responds to top_up" do
    expect(subject).to respond_to(:top_up).with(1).argument
  end

  it "tops up by an amount" do
    expect{subject.top_up 1}.to change{subject.balance}.by 1
  end

  it "has a maximum balance at 90" do
    max_balance = Oystercard::BALANCE_LIMIT
    subject.top_up(max_balance)
    expect{subject.top_up 1}.to raise_error "The limit is #{Oystercard::BALANCE_LIMIT}"
  end
end

describe '#deduct' do
  it 'deducts money from card' do
    subject.top_up(Oystercard::MIN_BALANCE)
    subject.touch_in(station)
    expect{subject.touch_out(station)}.to change{subject.balance}.by(-double_fare)
  end
end

describe "#touch_in(station)" do
  before(:each) do
    subject.top_up(Oystercard::MIN_BALANCE)
    subject.touch_in(station)
  end

  it   { expect(subject).to respond_to(:touch_in) }


  it "should return in journey when touched in" do
    expect(subject.in_journey?).to eq true
  end

  it "should return in journey when touched in" do
    subject.touch_out(station)
    message = "Insufficient funds, please top up #{Oystercard::MIN_BALANCE}"
    expect{subject.touch_in(station)}.to raise_error message
  end

  it "shoud return entry station when in journey" do
    expect(subject.in_journey?).to eq true
  end

end

describe "#touch_out(exit_station)" do
  before(:each) do
    subject.top_up(Oystercard::MIN_BALANCE * 5)
    subject.touch_in(station)
    subject.touch_out(station)
  end

  it   { expect(subject).to respond_to(:touch_out) }

  it "should return in journey when touched out" do
    expect(subject.in_journey?).to eq false
  end

  it "should charge when touching out" do
    subject.touch_in(station)
    expect{subject.touch_out(station)}.to change{subject.balance}.by(-Oystercard::MIN_BALANCE)
  end

  it "should return nil when not in journey" do
    expect(subject.in_journey?).to eq false
  end

  it "should record one journey (set of an entry and exit stations)" do
    expect(subject.journeys).to eq [journey]
    end
  end

  describe 'Incomplete journeys and penalty fares' do
    context 'Touching in twice' do
      before(:each) do
        subject.top_up(Oystercard::MIN_BALANCE)
        subject.touch_in(station)
      end
      it 'charges a penalty fare when user touches in twice consecutively' do
        expect{subject.touch_in(station)}.to change{subject.balance}.by(-Oystercard::PENALTY_FARE)
      end
    end
    context 'Touching out without having touched in' do
      it 'charges a penalty fare when user touches out only' do
        expect{subject.touch_out(station)}.to change{subject.balance}.by(-Oystercard::PENALTY_FARE)
      end
    end
  end
end
