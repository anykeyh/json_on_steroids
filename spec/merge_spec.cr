module MergeSpec
  describe JSON::OnSteroids::MergeOperations do
    it "can select few keys (tuple)" do
      json = JSON.parse(%<{"a": 1, "b": 2, "c": [1,2,3]}>).on_steroids!
      json = json % {"a", :b, "d"} # => {"a": 1, "b": 2}
      json.to_json.should eq %<{"a":1,"b":2}>
    end

    it "can remove some keys (tuple)" do
      json = JSON.parse(%<{"id": 1, "email": "me@example.tld", "encrypted_password": "XXXXXXXXXX"}>).on_steroids!
      json = json - { :encrypted_password }
      json.to_json.should eq %<{"id":1,"email":"me@example.tld"}>
    end

    it "can select few keys (array)" do
      json = JSON.parse(%<{"a": 1, "b": 2, "c": [1,2,3]}>).on_steroids!
      json = json % %i(a b d) # => {"a": 1, "b": 2}
      json.to_json.should eq %<{"a":1,"b":2}>
    end

    it "can remove some keys (array)" do
      json = JSON.parse(%<{"id": 1, "email": "me@example.tld", "encrypted_password": "XXXXXXXXXX"}>).on_steroids!
      json = json - [ "encrypted_password" ]
      json.to_json.should eq %<{"id":1,"email":"me@example.tld"}>
    end

    it "can merge a tuple (mutable)" do
      json = JSON::OnSteroids.new
      json["a"] = "b"

      json.to_json.should eq %<{"a":"b"}>

      json.merge!({
        c: "d"
      })

      json.to_json.should eq %<{"a":"b","c":"d"}>
    end

    it "can merge a tuple (immutable)" do
      json = JSON::OnSteroids.new
      json["a"] = "b"

      json.to_json.should eq %<{"a":"b"}>

      json2 = json.merge({
        c: "d"
      })

      json.to_json.should eq %<{"a":"b"}>
      json2.to_json.should eq %<{"a":"b","c":"d"}>
    end

  end
end