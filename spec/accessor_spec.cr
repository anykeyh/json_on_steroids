module AccessorSpec
  describe JSON::OnSteroids::Access do
    it "setter / getter []=(AuthorizedSetType)" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      now = Time.local
      now_str = '"' + now.to_utc.to_s("%FT%T.%LZ") + '"'

      {
        "5" => 5,
        "5.0" => 5.0,
        "\"String\"" => "String",
        "false" => false,
        "null" => nil,
        now_str => now,
        "[1,2,3]" => [1,2,3],
        "{\"a\":\"b\"}" => {"a" => "b"},
        "{\"a\":\"b\"}" => {a: "b"}
      }.each do |k, v|
        json["v"] = v
        json["v"].to_json.should eq(k)
      end
      json.dirty?.should be_true
    end

    it "setter / getter for array []=(Int, AuthorizedSetType)" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      now = Time.local
      now_str = '"' + now.to_utc.to_s("%FT%T.%LZ") + '"'

      {
        "5" => 5,
        "5.0" => 5.0,
        "\"String\"" => "String",
        "false" => false,
        "null" => nil,
        now_str => now,
        "[1,2,3]" => [1,2,3],
        "{\"a\":\"b\"}" => {"a" => "b"},
        "{\"a\":\"b\"}" => {a: "b"}
      }.each do |k, v|
        json["array"][0] = v
        json["array"][0].to_json.should eq(k)
      end

      json.dirty?.should be_true
    end

    it "array append <<(AuthorizedSetType)" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      json["array"] << "Hello world"
      json["array"].as_arr.last.as_s.should eq "Hello world"

      json.dirty?.should be_true
    end

    it "delete key/index" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      json["array"].delete
      json["array"]?.should eq nil

      item = json["array2"][1]
      item.delete

      item.parent.should be_nil
      item.key.should be_nil

      json["array2"][1].as_f.should eq(1.2) #< The next item is selected

      json.dirty?.should be_true
    end


  end
end