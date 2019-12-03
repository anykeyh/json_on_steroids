
module Clear::Model::Converter::JSON::OnSteroidConverter
  def self.to_column(x) : ::JSON::OnSteroid?
    case x
    when Nil
      nil
    when ::JSON::Any
      ::JSON::OnSteroid.new(x)
    else
      ::JSON::OnSteroid.new(::JSON.parse(x.to_s))
    end
  end

  def self.to_db(x : ::JSON::OnSteroid?)
    x.to_json
  end
end

Clear::Model::Converter.add_converter("JSON::OnSteroid", Clear::Model::Converter::JSON::OnSteroidConverter)
