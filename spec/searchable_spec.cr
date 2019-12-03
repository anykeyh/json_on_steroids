module DiggableSpec

  describe JSON::OnSteroids::Searchable do

    it "can dig through the structure" do
      json = JSON.parse(%<{"other": {"counter": 123}}>).on_steroids!

      json.dig("other.counter").set(&.as_i.+ 1) # Add 1 to the counter
      json.to_json.should eq(%<{"other":{"counter":124}}>)

      json.dig("other.counter").delete
      puts json.to_json.should eq(%<{"other":{}}>)
    end
  end
end