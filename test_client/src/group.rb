# frozen_string_literal: true

require_relative 'group_v0'
require_relative 'group_v1'
require_relative 'group_v2'

class Group

  def initialize(externals)
    @target = target(externals)
  end

  def method_missing(name, *arguments, &block)
    @target.send(name, *arguments, &block)
  end

  private

  def target(externals)
    name = ENV['CYBER_DOJO_TEST_NAME']
    if v_test?(name,0)
      Group_v0.new(externals)
    elsif v_test?(name,1)
      Group_v1.new(externals)
    else
      Group_v2.new(externals)
    end
  end

  def v_test?(name,n)
    name.start_with?("<version=#{n.to_s}>")
  end

end