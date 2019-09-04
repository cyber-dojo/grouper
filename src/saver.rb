# frozen_string_literal: true

require 'open3'

class Saver

  def sha
    ENV['SHA']
  end

  def ready?
    true
  end

  def alive?
    true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def exists?(key)
    Dir.exist?(path_name(key))
  end

  def create(key)
    # Returns true iff key's dir does not already exist and
    # is made. Can't find a Ruby library method for this
    # (FileUtils.mkdir_p does not tell) so using shell.
    #   -p creates intermediate dirs as required.
    #   -v verbose mode, output each dir actually made
    command = "mkdir -vp '#{path_name(key)}'"
    stdout,stderr,r = Open3.capture3(command)
    stdout != '' && stderr === '' && r.exitstatus === 0
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def write(key, value)
    mode = File::WRONLY | File::CREAT | File::EXCL
    File.open(path_name(key), mode) { |fd|
      fd.write(value)
    }
    true
  rescue Errno::ENOENT, # dir does not exist
         Errno::EEXIST  # file already exists
    false
  end

  def append(key, value)
    mode = File::WRONLY | File::APPEND
    File.open(path_name(key), mode) { |fd|
      fd.flock(File::LOCK_EX)
      fd.write(value)
    }
    true
  rescue Errno::ENOENT # file does not exist
    false
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def read(key)
    mode = File::RDONLY
    File.open(path_name(key), mode) { |fd|
      fd.flock(File::LOCK_EX)
      fd.read
    }
  rescue Errno::ENOENT, # file does not exist
         Errno::EISDIR  # file is a dir!
    nil
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def batch(commands)
    commands.map do |command|
      name,*args = command
      case name
      when 'create' then create(*args)
      when 'exists' then exists?(*args)
      when 'write'  then write(*args)
      when 'append' then append(*args)
      when 'read'   then read(*args)
      end
    end
  end

  private

  def path_name(key)
    File.join('', 'cyber-dojo', key)
  end

end
