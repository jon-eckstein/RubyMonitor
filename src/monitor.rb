#!/usr/bin/ruby
=begin
Jonathan Eckstein
CS177
Hw4
=end

#have a loop to go through and call who-u
#save the results to an array...
#compare to first array and see who's logged in who's logged off...
#display who logged in and who logged out...

require 'yaml'

CONFIG_FILE = "monitor.conf"
LINE_THRESHOLD = 25
@config = {}
@config_read_time = ""
def strip_first_and_last_char(val)
  val.reverse.chop.reverse.chop
end

def who_is_logged_in()
  if(@config["users"] == "all")
    reg_exp = "."
  else
    reg_exp = @config["users"]
  end
  `who -R | grep #{reg_exp}`.split(Regexp.new('\n'))  
end

def in?(ar, val)
  ar.any? { |obj| obj == val }
end

def yes_or_no?(val)
  in?(["yes","no"], val)
end

def validate_config()

  raise ArgumentError, "Config no loaded." if(@config.nil?)
  raise ArgumentError, "Invalid status arugument" unless(in?(["login_logoff", "login_only", "logoff_only"], @config["status"]))
  raise ArgumentError,"Invalid show_ip_address" unless(yes_or_no?(@config["show_ip_address"]))
  raise ArgumentError, "Invalid duration" unless(@config["duration"] == "forever" ||  @config["duration"].to_i != 0)
  raise ArgumentError, "Invalid clear_screen" unless(yes_or_no?(@config["clear_screen"]))
  raise ArgumentError, "Invalid show_time" unless(yes_or_no?(@config["show_time"]))
end


def read_config()
  open(CONFIG_FILE,"r") do |handle|
    @config = YAML.load(handle)
  end
  validate_config
  @config_read_time = Time.now
end


def continue?
  return true if(@config["duration"] == "forever")  
  return (Time.now - @config_read_time).to_i < @config["duration"].to_i
end


#trap("SIGHUP") { read_config  }
#trap("SIGINT","IGNORE")

puts "reading config file..."
read_config

past = who_is_logged_in()

puts "monitoring...."

line_counter=0

while(continue?)
  sleep(1)
  current = who_is_logged_in()
  logged_out = past - current
  logged_in = current - past


  logged_out.each do |item|
      items = item.split
      line = items.first
      line += " logged out from " + strip_first_and_last_char(items.last) if(@config["show_ip_address"] == "yes")
      line += " @ " + items[2] + items[3] + items[4] if(@config["show_time"] == "yes")
      line_counter+=1
      puts line
    end if (in?(["login_logoff", "logoff_only"], @config["status"]))

  logged_in.each do |item|
    items = item.split
    line = items.first
    line += " logged in from " + strip_first_and_last_char(items.last) if(@config["show_ip_address"] == "yes")
    line += " @ " + Time.now.to_s if(@config["show_time"] == "yes")
    line_counter += 1
    puts line
  end if (in?(["login_logoff", "login_only"], @config["status"]))

  past = current


  if(@config["show_time"] == "yes" && line_counter >= LINE_THRESHOLD)
    `clear`
  end

end

puts "Monitor complete"
