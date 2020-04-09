require_relative 'test_base'
require_relative '../src/saver'

class SaverAssertTest < TestBase

  def self.hex_prefix
    'FA2'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # assert()

  test '538',
  'assert() raises when its command is not true' do
    dirname = 'groups/Fw/FP/3p'
    error = assert_raises(RuntimeError) {
      saver.assert(saver.dir_exists_command(dirname))
    }
    assert_equal 'command != true', error.message
    refute saver.exists?(dirname)
  end

  test '539',
  'assert() returns command result when command is true' do
    dirname = 'groups/sw/EP/7K'
    filename = dirname + '/' + '3.events.json'
    content = '{"colour":"red"}'
    saver.create(dirname)
    saver.write(filename, content)
    read = saver.assert(saver.file_read_command(filename))
    assert_equal content, read
  end

end