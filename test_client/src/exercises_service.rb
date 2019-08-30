require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'http_service_exception'
require 'net/http'

class ExercisesService

  def initialize
    requester = HttpJson::RequestPacker.new(Net::HTTP, 'exercises', 4525)
    @http = HttpJson::ResponseUnpacker.new(requester, HttpServiceException)
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end