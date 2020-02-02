
module MiscSpec
  describe JSON::OnSteroids do

    it "parse real-life example provided by the users" do
      raw_json = %Q[{"gdo_lock_connected":false,"attached_work_light_error_present":false,"door_state":"closed","open":"http://test.com/api/v5/accounts/6d3cbc42-22a4-0123-1234-abc53035abcd/devices/CG08400F9999/close","last_update":"2020-01-26T18:51:48.3816064Z","passthrough_interval":"00:00:00","door_ajar_interval":"00:00:00","invalid_credential_window":"00:00:00","invalid_shutout_period":"00:00:00","is_unattended_open_allowed":true,"is_unattended_close_allowed":true,"aux_relay_delay":"00:00:00","use_aux_relay":false,"aux_relay_behavior":"None","rex_fires_door":false,"command_channel_report_status":false,"control_from_browser":false,"report_forced":false,"report_ajar":false,"max_invalid_attempts":0,"online":true,"last_status":"2020-01-26T23:22:11.1467933Z"}]
      json = JSON::OnSteroids.new(JSON.parse(raw_json))
    end
  end
end
