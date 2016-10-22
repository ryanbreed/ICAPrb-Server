require 'redis'
module ICAPrb
  module Server
    module Services
      class RedisSniffer < ServiceBase
        # initializes the RedisSniffer - the name of the service is sniff
        def initialize
          super('sniff',[:request_mod, :response_mod],1024,60,nil,nil,nil,1000)
          @timeout = nil
        end

        # return the request to the client
        def process_request(icap_server,ip,socket,data)
          logger = icap_server.logger
          logger.debug 'Start processing data via echo service...'
          response = ::ICAPrb::Server::Response.new
          response.icap_status_code = 200
          if data[:icap_data][:request_line][:icap_method] == :response_mod
            http_resp_header = data[:http_response_header]
            http_resp_body = data[:http_response_body]
          else
            http_resp_header = data[:http_request_header]
            http_resp_body = data[:http_request_body]
          end

          http_resp_body << get_the_rest_of_the_data(socket) if http_resp_body && !(got_all_data? data)
          response.components << http_resp_header
          response.components << http_resp_body
          response.write_headers_to_socket socket
          if http_resp_body.instance_of? ResponseBody
            socket.write(http_resp_body.to_chunk)
            ::ICAPrb::Server::Response.send_last_chunk(socket,false)
          end
          logger.debug 'Answered request in echo service'
        end
      end
    end
  end
end
