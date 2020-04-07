
require_relative 'test_base'
require_relative '../src/saver_service'
require_relative 'saver_service_fake'

class SaverPrimitiveTest < TestBase

  def self.hex_prefix
    'AD4'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  REAL_TEST_MARK = '<real>'
  FAKE_TEST_MARK = '<fake>'

  def self.multi_test(hex_suffix, *lines, &block)
    real_lines = [REAL_TEST_MARK] + lines
    test(hex_suffix+'0', *real_lines, &block)
    fake_lines = [FAKE_TEST_MARK] + lines
    test(hex_suffix+'1', *fake_lines, &block)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def saver
    if fake_test?
      @saver ||= SaverServiceFake.new
    else
      @saver ||= SaverService.new
    end
  end

  def fake_test?
    test_name.start_with?(FAKE_TEST_MARK)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : exists?(), create()

  multi_test '431',
  'exists?(dirname) is false before create(dirname) and true after' do
    dirname = 'client/34/X7/a8'
    refute exists?(dirname)
    assert create(dirname)
    assert exists?(dirname)
  end

  multi_test '432',
  'create(dirname) succeeds once and then fails' do
    dirname = 'client/r5/X7/03'
    assert create(dirname)
    refute create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : write()

  multi_test '640', %w(
    write(filename) succeeds
    when its dir of filename exists and filename does not exist
  ) do
    dirname = 'client/32/Xg/9j'
    assert create(dirname)
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    assert write(filename, content)
    assert_equal content, read(filename)
  end

  multi_test '641', %w(
    write(filename) fails
    when its dir of filename does not already exist
  ) do
    dirname = 'client/5e/X4/Aa'
    # no create(dirname)
    filename = dirname + '/readme.md'
    refute write(filename, 'bonjour')
    assert read(filename).is_a?(FalseClass)
  end

  multi_test '642', %w(
    write(filename,content) fails
    when filename already exists
  ) do
    dirname = 'client/73/Xf/69'
    assert create(dirname)
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    assert write(filename, first_content)
    refute write(filename, 'second-content')
    assert_equal first_content, read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : append()

  multi_test '840', %w(
    append(filename,content) returns true and appends to the end of filename
    when filename already exists
  ) do
    dirname = 'client/69/Xb/2B'
    assert create(dirname)
    filename = dirname + '/readme.md'
    content = 'helloooo'
    assert write(filename, content)
    more = 'some-more'
    assert append(filename, more)
    assert_equal content+more, read(filename)
  end

  multi_test '841', %w(
    append(filename,content) returns false and does nothing
    when its dir of filename does not already exist
  ) do
    dirname = 'client/96/X8/59'
    # no create(dirname)
    filename = dirname + '/readme.md'
    refute append(filename, 'greetings')
    assert read(filename).is_a?(FalseClass)
  end

  multi_test '842', %w(
    append(filename,content) does nothing and returns false
    when dir of filenme exists and filename does not exist
  ) do
    dirname = 'client/96/X8/59'
    assert create(dirname)
    filename = dirname + '/hiker.h'
    # no write(filename, '...')
    refute append(filename, 'int main(void);')
    assert read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run : read()

  multi_test '437',
  'read(filename) reads what a successful write(filename,content) writes' do
    dirname = 'client/FD/X4/38'
    assert create(dirname)
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert write(filename, content)
    assert_equal content, read(filename)
  end

  multi_test '438',
  'read() returns false given a non-existent file-name' do
    filename = 'client/1z/X3/e4/not-there.txt'
    assert saver.run(saver.read_command(filename)).is_a?(FalseClass)
  end

  multi_test '439',
  'read(filename) returns false given an existing dirname' do
    dirname = 'client/2f/Xk/3P'
    create(dirname)
    assert read(dirname).is_a?(FalseClass)
  end

  private

  def create(dirname)
    saver.create(dirname)
  end

  def exists?(dirname)
    saver.exists?(dirname)
  end

  def write(filename, content)
    saver.write(filename, content)
  end

  def append(filename, content)
    saver.append(filename, content)
  end

  def read(filename)
    saver.read(filename)
  end

end
