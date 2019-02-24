module MergeSpec
  describe JSON::OnSteroids::MergeOperations do
    it "can select few keys" do
      json = JSON.parse(%<{"a": 1, "b": 2, "c": [1,2,3]}>).on_steroids!
      json = json % {"a", :b, "d"} # => {"a": 1, "b": 2}
      json.to_json.should eq %<{"a":1,"b":2}>
    end

    it "can remove some keys" do
      json = JSON.parse(%<{"id": 1, "email": "me@example.tld", "encrypted_password": "XXXXXXXXXX"}>).on_steroids!
      json = json - { :encrypted_password }
      json.to_json.should eq %<{"id":1,"email":"me@example.tld"}>
    end
  end
end