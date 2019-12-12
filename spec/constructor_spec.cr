require "./spec_helpers"

module ConstructorSpec
  describe JSON::OnSteroids do
    it "can construct from JSON::Any" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!
      json.to_json.should eq %({"boolean":true,"time":1234,"float":1.2,"array":[1,2,3,4,5],"array2":[true,1,1.2,null,"hello"],"hash":{"a":1,"b":true}})

      json = JSON::OnSteroids.parse(FULL_EXAMPLE_JSON)
      json.to_json.should eq %({"boolean":true,"time":1234,"float":1.2,"array":[1,2,3,4,5],"array2":[true,1,1.2,null,"hello"],"hash":{"a":1,"b":true}})
    end

    it "can construct from Hash" do
      json = JSON::OnSteroids.new({
        "A" => {
          "B" => 1,
          "C" => nil,
          "D" => [1_i64, false, "yey", 1.0],
          "E" => 3.5_f32
        }
      })

      json.to_json.should eq %({"A":{"B":1,"C":null,"D":[1,false,"yey",1.0],"E":3.5}})
    end

    it "can construct from primitives" do
      # New object hash
      JSON::OnSteroids.new.to_json.should eq "{}"

      #
      JSON::OnSteroids.new("string").to_json.should eq "\"string\""
      JSON::OnSteroids.new(1).to_json.should eq "1"
      JSON::OnSteroids.new(1.2).to_json.should eq "1.2"
      JSON::OnSteroids.new(true).to_json.should eq "true"
      JSON::OnSteroids.new(nil).to_json.should eq "null"
    end

    it "can construct from array" do
      JSON::OnSteroids.new([] of String).to_json.should eq "[]"
      JSON::OnSteroids.new([1,2,3]).to_json.should eq "[1,2,3]"
    end

    it "can construct from NamedTuple" do
      JSON::OnSteroids.new(a: 1, b: [2], c: {d: 4}).to_json.should eq %({"a":1,"b":[2],"c":{"d":4}})
    end
  end
end