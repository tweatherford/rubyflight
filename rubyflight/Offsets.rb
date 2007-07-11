module RubyFlight
  attr_reader(:offsets)
  
  def load_offsets
    @offsets = {
      :heading => [ 0x580, 4, :uint ],
      :pitch => [ 0x578, 4, :int ],
      :bank => [ 0x57C, 4, :int ],
      :altitude_fract => [ 0x570, 4, :uint ], :altitude_unit => [ 0x574, 4, :int ],
      :radio_altitude => [ 0x31E4, 4, :uint ],
      :ground_altitude => [ 0x20, 4, :uint ],
      :on_ground => [ 0x366, 2, :uint ],
      :parking_brake => [ 0xBC8, 2, :int ],
      :ground_speed => [ 0x2B4, 4, :int ],
      :tas => [ 0x2B8, 4, :int ],
      :ias => [ 0x2BC, 4, :int ],
      :pushback => [ 0x31F0, 4, :uint ],
      :latitude_fract => [ 0x560, 4, :uint ], :latitude_unit => [ 0x564, 4, :int ],
      :longitude_fract => [ 0x568, 4, :uint ], :latitude_unit => [ 0x56C, 4, :int ],
      :doors_open => [ 0x3367, 1, :uint ],
      :altimeter => [ 0x330, 2, :uint ],
      :vs_last => [ 0x30C, 4, :int ],
      :vs => [ 0x2c8, 4, :int],
      
      :engines_number => [ 0xAEC, 2, :int ],
      
      :fuel_flow_1 => [ 0x918, 0, :real ], :fuel_flow_2 => [ 0x9B0, 0, :real ],
      :fuel_flow_3 => [ 0xA48, 0, :real ], :fuel_flow_4 => [ 0xAE0, 0, :real ],
      :fuel_valve_1 => [ 0x3590, 4, :uint ], :fuel_valve_2 => [ 0x3594, 4, :uint ],
      :fuel_valve_3 => [ 0x3598, 4, :uint ], :fuel_valve_4 => [ 0x359c, 4, :uint ],
      :tank_center_level => [ 0xB74, 4, :int ], :tank_center_capacity => [ 0xB78, 4, :int ],
      :tank_right_main_level => [ 0xB94, 4, :int ], :tank_right_aux_level => [ 0xB9C, 4, :int ], :tank_right_tip_level => [ 0xBA4, 4, :int ],
      :tank_left_main_level => [ 0xB7C, 4, :int ], :tank_left_aux_level => [ 0xB84, 4, :int ], :tank_left_tip_level => [ 0xB8C, 4, :int ],
      :tank_right_main_capacity => [ 0xB98, 4, :int ], :tank_right_aux_capacity => [ 0xBA0, 4, :int ], :tank_right_tip_capacity => [ 0xBA8, 4, :int ],
      :tank_left_main_capacity => [ 0xB80, 4, :int ], :tank_left_aux_capacity => [ 0xB88, 4, :int ], :tank_left_tip_capacity => [ 0xB90, 4, :int ],
      
      :qnh => [ 0x34A0, 0, :real ],
      
      :message => [ 0x3380, 0, :string ], :send_message => [ 0x32FA, 0, :string ],
      :initialized => [ 0x4D6, 2, :uint ]
    }
  end
end
