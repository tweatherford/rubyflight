begin
  puts "#{ARGV[0]} #{ARGV[1]}"
  airports = nil
  File.open('airports.dump', 'r') {|io| airports = Marshal.load(io)}
  puts airports[ARGV[0].to_i][ARGV[1].to_i].keys.join(',')
end