#!/ust/bin/env ruby
require "bundler/setup"
require "icaprb/server"
require "icaprb/server/services/redis_sniffer"
require 'logger'
include ICAPrb::Server

trap('SIGINT') { exit! 0 }

s = ICAPServer.new('localhost',1344)
puts 'Server is running on port 1344. Press CTRL+C to exit...'
s.logger.level = Logger::DEBUG
s.services['echo'] = Services::EchoService.new
sniffer = Services::RedisSniffer.new
sniffer.redis=Redis.new(url: 'redis://127.0.0.1:6379/1')

s.services['sniff'] = sniffer

s.run
