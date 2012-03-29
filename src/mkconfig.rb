#!/usr/bin/ruby -w

require 'yaml'


config = {
  "status" => "login_logoff",
  "show_ip_address" => "yes",
  "duration" => "forever",
  "users" => "all",
  "clear_screen" => "no",
  "show_time" => "yes",

}

open("monitor.conf", "w") do | handle|
  YAML.dump(config, handle)
end