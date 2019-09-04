require_relative 'test_base'
require_relative '../src/saver'

class SaverTest < TestBase

  def self.hex_prefix
    'FDF'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha

  test '190', %w( sha is sha of image's git commit ) do
    sha = saver.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # ready?

  test '602',
  %w( ready? is always true ) do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # alive?

  test '603',
  %w( alive? is always true ) do
    assert saver.alive?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?(), create()

  test '431',
  'exists?(k) is false before create(k) and true after' do
    dirname = 'groups/34/f7/a8'
    refute saver.exists?(dirname)
    assert saver.create(dirname)
    assert saver.exists?(dirname)
  end

  test '432',
  'create succeeds once and then fails' do
    dirname = 'groups/r5/s7/03'
    assert saver.create(dirname)
    refute saver.create(dirname)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  test '640', %w(
    write() succeeds
    when its dir-name exists and its file-name does not exist
  ) do
    dirname = 'groups/32/fg/9j'
    assert saver.create(dirname)
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '641', %w(
    write() fails
    when its dir-name does not already exist
  ) do
    dirname = 'groups/5e/94/Aa'
    # saver.create(dirname) # missing
    filename = dirname + '/readme.md'
    refute saver.write(filename, 'bonjour')
    assert saver.read(filename).is_a?(FalseClass)
  end

  test '642', %w(
    write() fails
    when its file-name already exists
  ) do
    dirname = 'groups/73/Ff/69'
    assert saver.create(dirname)
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    assert saver.write(filename, first_content)
    refute saver.write(filename, 'second-content')
    assert_equal first_content, saver.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  test '840', %w(
    append() returns true and appends to the end of file-name
    when file-name already exists
  ) do
    dirname = 'groups/69/1b/2B'
    assert saver.create(dirname)
    filename = dirname + '/readme.md'
    content = 'helloooo'
    assert saver.write(filename, content)
    more = 'some-more'
    assert saver.append(filename, more)
    assert_equal content+more, saver.read(filename)
  end

  test '841', %w(
    append() returns false and does nothing
    when its dir-name does not already exist
  ) do
    dirname = 'groups/96/18/59'
    # saver.create(dirname) # missing
    filename = dirname + '/readme.md'
    refute saver.append(filename, 'greetings')
    assert saver.read(filename).is_a?(FalseClass)
  end

  test '842', %w(
    append() does nothing and returns false
    when its file-name does not already exist
  ) do
    dirname = 'groups/96/18/59'
    assert saver.create(dirname)
    filename = dirname + '/hiker.h'
    # saver.write(filename, '...') # missing
    refute saver.append(filename, 'int main(void);')
    assert saver.read(filename).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  test '437',
  'read() gives back what a successful write() accepts' do
    dirname = 'groups/FD/F4/38'
    assert saver.create(dirname)
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert saver.write(filename, content)
    assert_equal content, saver.read(filename)
  end

  test '438',
  'read() returns false given a non-existent file-name' do
    filename = 'groups/1z/23/e4/not-there.txt'
    assert saver.read(filename).is_a?(FalseClass)
  end

  test '439',
  'read() returns false given an existing dir-name' do
    dirname = 'groups/2f/7k/3P'
    saver.create(dirname)
    assert saver.read(dirname).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # batch()

  test '514',
  'batch() batches all other commands' do
    expected = []
    commands = []

    dirname = 'batch/e3/t6/A8'
    commands << ['create',dirname]
    expected << true

    commands << ['exists',dirname]
    expected << true

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    commands << ['write',there_yes,content]
    expected << true

    commands << ['append',there_yes,content.reverse]
    expected << true

    commands << ['read',there_yes]
    expected << content+content.reverse

    there_not = dirname + '/there-not.txt'
    commands << ['read',there_not]
    expected << false

    result = saver.batch(commands)
    assert_equal expected, result
  end

end
