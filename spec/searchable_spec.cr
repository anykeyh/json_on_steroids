module DiggableSpec

  describe JSON::OnSteroids::Searchable do

    it "can dig through the structure" do
      json = JSON.parse(%<{"other": {"counter": 123}}>).on_steroids!

      json.dig("other.counter").set(&.as_i.+ 1) # Add 1 to the counter
      json.to_json.should eq(%<{"other":{"counter":124}}>)

      json.dig("other.counter").delete
      json.to_json.should eq(%<{"other":{}}>)

      expect_raises JSON::OnSteroids::Exception do
        json.dig("other.counter_not_exists").set(&.as_i.+ 1)
      end

      json.clean!
      json.dirty?.should be_false
      json.dig?("other.counter_not_exists").try &.set(&.as_i.+ 1) #Should not do anything
      json.dirty?.should be_false
      json.dig("other").set{ {counter: 124_i64} } #< Add directly to the key other, the previous counter
      json.dig?("other.counter").try &.set(&.as_i.+ 1) #Should not do anything

      json.to_json.should eq(%<{"other":{"counter":125}}>)
    end
  end
end
