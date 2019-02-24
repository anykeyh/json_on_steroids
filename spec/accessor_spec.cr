module AccessorSpec
  describe JSON::OnSteroids::Access do
    it "setter / getter []=(AuthorizedSetType)" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      now = Time.now
      now_str = now.to_utc.to_s("%FT%T.%LZ")

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
    end

    it "setter / getter for array []=(Int, AuthorizedSetType)" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      now = Time.now
      now_str = now.to_utc.to_s("%FT%T.%LZ")

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

    end

    it "array append <<(AuthorizedSetType)" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      json["array"] << "Hello world"
      json["array"].as_arr.last.as_s.should eq "Hello world"
    end

    it "delete key/index" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      json["array"].delete
      json["array"]?.should eq nil

      json["array2"][1].delete
      json["array2"][1].as_f.should eq(1.2)
    end

    pending "merge hash" do
      json = JSON.parse(FULL_EXAMPLE_JSON).on_steroids!

      json.merge!({"a" => "b", "hash" => { "a" => 1, "c"=> 3 } } )

      json["a"]
    end


  end
end