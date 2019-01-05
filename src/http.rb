require_relative 'service_error'
require_relative 'http_helper'
require 'json'

class Http

  def initialize(parent, hostname, port)
    @helper = HttpHelper.new
    @parent = parent
    @hostname = hostname
    @port = port
  end

  def get(*args)
    call('get', name_of(caller), *args)
  end

  private

  attr_reader :helper, :parent, :hostname, :port

  def name_of(caller)
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  def call(gp, method, *args)
    json = helper.public_send(gp, hostname, port, method, args_hash(method, *args))
    fail_unless(method, 'bad json') { json.class.name == 'Hash' }
    exception = json['exception']
    fail_unless(method, pretty(exception)) { exception.nil? }
    fail_unless(method, 'no key') { json.key?(method) }
    json[method]
  end

  def args_hash(method, *args)
    # Uses reflection to create a hash of args where each key is
    # the parameter name. For example, differ_services does this
    #
    #   def diff(was_files, now_files)
    #     http.get(__method__, was_files, now_files)
    #  end
    #
    # Reflection sees the names of diff()'s parameters are
    # 'was_files' and 'now_files' and so constructs the hash
    # { 'was_files' => args[0], 'now_files' => args[1] }
    parameters = parent.class.instance_method(method).parameters
    parameters.map
              .with_index { |parameter,index| [parameter[1], args[index]] }
              .to_h
  end

  def fail_unless(name, message, &block)
    unless block.call
      fail ServiceError.new(parent.class.name, name, message)
    end
  end

  def pretty(json)
    JSON.pretty_generate(json)
  end

end
