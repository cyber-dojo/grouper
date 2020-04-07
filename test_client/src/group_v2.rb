# frozen_string_literal: true

require_relative 'oj_adapter'
require_relative 'saver_asserter'

# 1. Manifest now has explicit version (2)
# 2. joined() now does a single read rather than 64.
# 3. No longer stores JSON in pretty format.
# 4. No longer stores file contents in lined format.
# 5. Uses Oj as its JSON gem.

class Group_v2

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    saver.send(*exists_cmd(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = generate_id
    manifest['version'] = 2
    saver.batch_assert([
      manifest_write_cmd(id, json_plain(manifest)),
      katas_write_cmd(id, '')
    ])
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.send(*manifest_read_cmd(id))
    saver_assert(manifest_src.is_a?(String))
    json_parse(manifest_src)
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    manifest = self.manifest(id)
    manifest.delete('id')
    manifest['group_id'] = id
    indexes.each do |index|
      if saver.send(*create_cmd(id, index))
        manifest['group_index'] = index
        kata_id = kata.create(manifest)
        result = saver.send(*katas_append_cmd(id, "#{kata_id} #{index}\n"))
        saver_assert(result)
        return kata_id
      end
    end
    nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    katas_indexes(id).map{ |kid,_| kid }
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    result = {}
    kindexes = katas_indexes(id)
    read_events_files_commands = kindexes.map do |kid,_|
      kata.send(:events_read_cmd, kid)
    end
    katas_events = saver_assert_batch(read_events_files_commands)
    kindexes.each.with_index(0) do |(kid,kindex),index|
      result[kid] = {
        'index' => kindex.to_i,
        'events' => events_parse(katas_events[index])
      }
    end
    result
  end

  private

  include OjAdapter
  include SaverAsserter

  # - - - - - - - - - - - - - - - - - - - - - -

  def generate_id
    42.times do
      id = id_generator.id
      if saver.create(id_path(id))
        return id
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create_cmd(id, *parts)
    ['create', id_path(id, *parts)]
  end

  def exists_cmd(id)
    ['exists?', id_path(id)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_write_cmd(id, manifest_src)
    ['write', manifest_filename(id), manifest_src]
  end

  def manifest_read_cmd(id)
    ['read', manifest_filename(id)]
  end

  def manifest_filename(id)
    id_path(id, 'manifest.json')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_write_cmd(id, src)
    ['write', katas_filename(id), src]
  end

  def katas_append_cmd(id, src)
    ['append', katas_filename(id), src]
  end

  def katas_read_cmd(id)
    ['read', katas_filename(id)]
  end

  def katas_filename(id)
    id_path(id, 'katas.txt')
  end

  def katas_indexes(id)
    katas_src = saver.send(*katas_read_cmd(id))
    saver_assert(katas_src)
    katas_src.split.each_slice(2).to_a
    # [
    #   ['w34rd5', '2'], #  2 == bat
    #   ['G2ws77','15'], # 15 == fox
    #   ...
    # ]
  end

  # - - - - - - - - - - - - - -

  def events_parse(s)
    json_parse('[' + s + ']') # See json_speed_test.rb
  end

  # - - - - - - - - - - - - - -

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['groups', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

  def id_generator
    @externals.id_generator
  end

  def kata
    @externals.kata
  end

end
