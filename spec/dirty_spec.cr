module DirtySpec
  describe JSON::OnSteroids::Dirty do
    it "can be dirty" do
      json = JSON.parse(%<{"a": 1, "b": 2, "c": [1,2,3]}>).on_steroids!
      json.dirty?.should be_false

      json["d"] = "1"
      json.dirty?.should be_true
    end

    it "can output the dirty keys" do
      json = JSON::OnSteroids.new

      json.create_obj("a").create_obj("b")["c"] = 1

      json.to_json.should eq %<{"a":{"b":{"c":1}}}>

      json.dig("a.b")["d"] = "Hello World!"

      json.to_json.should eq %<{"a":{"b":{"c":1,"d":"Hello World!"}}}>

      # Basically, as of now everything is dirty!
      json.dirty_only.to_json.should eq %<{"a":{"b":{"c":1,"d":"Hello World!"}}}>

      # Let's clean the dirty flag
      json.clean!

      # Let's mutate a component:
      json.dig("a.b.d").set("Not Hello World!")

      json.to_json.should eq %<{"a":{"b":{"c":1,"d":"Not Hello World!"}}}>
      json.dirty_only.to_json.should eq %<{"a":{"b":{"d":"Not Hello World!"}}}>
    end
  end
end
