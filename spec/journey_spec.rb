require 'journey'
require 'oystercard'

describe Journey do
let (:station) {double :station, name: "Aldgate", zone: 1}
let (:station2) {double :station, name: "Northfields", zone: 3}
subject (:journey) {Journey.new(station)}

  context 'Set stations' do
    it 'has an entry station' do
      expect(subject.entry).to eq station
    end

    it 'has an exit station' do
      subject.exit = station
      expect(subject.exit).to eq station
    end
  end

  context 'In journey?' do
    it 'returns false when not in a journey' do
      expect(subject).to be_in_journey
    end

    it 'returns true when in a journey' do
      subject.exit = station
      expect(subject).not_to be_in_journey
    end
  end

  context 'Setting fare' do
    it 'returns the appropriate fare based on the zones travelled between' do
      subject.exit = station2
      expect(subject.fare).to eq (station.zone - station2.zone).abs + Oystercard::MIN_BALANCE
    end
  end

end
