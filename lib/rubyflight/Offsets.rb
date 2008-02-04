module RubyFlight
  module Offsets
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
        :longitude_fract => [ 0x568, 4, :uint ], :longitude_unit => [ 0x56C, 4, :int ],
        :doors_open => [ 0x3367, 1, :uint ],
        :altimeter => [ 0x330, 2, :uint ],
        :vs_last => [ 0x30C, 4, :int ],
        :vs => [ 0x2c8, 4, :int],
        :crashed => [ 0x840, 2, :uint ], :crashed_off_runway => [ 0x848, 2, :uint ],
        :gforce => [ 0x11BA, 2, :int ],
        :lateral_acceleration => [ 0x3060, 0, :real ], :vertical_acceleration => [ 0x3068, 0, :real ], :longitudinal_acceleration => [ 0x3070, 0, :real ], 
        :structural_deice => [ 0x337D, 1, :uint ], :surface_condition => [ 0x31EC, 4, :uint ],
        :hydraulic_failures => [ 0x32F8, 1, :uint ],
        :gear_control => [ 0xBE8, 4, :uint], 
        :nose_gear_control => [ 0xBEC, 4, :uint], :right_gear_control => [ 0xBF4, 4, :uint], :left_gear_control => [ 0xBF0, 4, :uint], 
        :left_brake => [ 0xBC4, 2, :uint ], :right_brake => [ 0xBC6, 2, :uint ],
        :left_brake_pressure => [ 0xC00, 1, :uint ], :right_brake_pressure => [ 0xC01, 1, :uint ],
        
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
        :initialized => [ 0x4D6, 2, :uint ], :simulation_rate => [ 0xC1A, 2, :uint ],
        
        :time_local_hour => [ 0x238, 1, :uint ], :time_local_minute => [ 0x239, 1, :uint ], :time_second => [ 0x23A, 1, :uint ], 
        :time_gmt_hour => [ 0x23B, 1, :uint ], :time_gmt_minute => [ 0x23C, 1, :uint ],
        :time_day => [ 0x23E, 2, :uint ], :time_year => [ 0x240, 2, :uint ],
        :timezone => [ 0x246, 2, :int ], :season => [ 0x248, 2, :uint ]
      }
    end
  end
end