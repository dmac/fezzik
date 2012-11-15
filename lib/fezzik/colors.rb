module Fezzik
  COLORS = { red: 1, green: 2 }
  def self.color_string(string, color)
    return string unless STDOUT.isatty
    "\e[01;#{COLORS[color]+30}m#{string}\e[m"
  end
end
