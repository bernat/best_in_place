#encoding: utf-8
module UsersHelper
  def height_collection
    {
        'h51' => %{5' 1"},
        'h52' => %{5' 2"},
        'h53' => %{5' 3"},
        'h54' => %{5' 4"},
        'h55' => %{5' 5"},
        '5\' 6"' => %{5' 6"}, # Using space and quotes in value is just asking for troubles
        '5\' 7"' => %{5' 7"},
        'h58' => %{5' 8"},
        'h59' => %{5' 9"},
        '5\' 10"' => %{5' 10"},
        'h511' => %{5' 11"},
        'h60' => %{6' 0"},
        'h61' => %{6' 1"},
        'h62' => %{6' 2"},
        'h63' => %{6' 3"},
        'h64' => %{6' 4"},
        'h65' => %{6' 5"},
        'h66' => %{6' 6"}
    }
  end

  def bb(value)
    "#{value} €"
  end

  def snacks_options
      Hash[ ["Twizzlers", "Whoppers", "Krispy Kremes", "Sun Chips", "Kit Kat", "Kettle Corn"].map { |o| [o.downcase.gsub(/\s+/, '-'), o] } ]
  end
end
