class JSON::OnSteroids::Exception < Exception
end

class JSON::OnSteroids::KeyNotFoundException < JSON::OnSteroids::Exception; end

class JSON::OnSteroids::NotAnArray < JSON::OnSteroids::Exception; end

class JSON::OnSteroids::NotAnObject < JSON::OnSteroids::Exception; end