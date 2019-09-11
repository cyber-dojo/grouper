# frozen_string_literal: true

require_relative 'oj_adapter'
require_relative 'saver_asserter'

# 1. Manifest now has explicit version (2)
# 2. Manifest is retrieved in single read call.
# 3. No longer stores JSON in pretty format.
# 4. No longer stores file contents in lined format.
# 5. Uses Oj as its JSON gem.
# 6. Stores explicit index in events.json summary file.
#    This makes using index==-1 robust when traffic-lights
#    are lost due to Saver outages.
#    was    { ... } # 0
#           { ... } # 1      then 2-23 outage
#           { ... } # 24
#    now    { ..., "index" => 0 }
#           { ..., "index" => 1 }
#           { ..., "index" => 24 }
# 7. No longer uses separate dir for each event file.
#    This makes ran_tests() faster as it no longer needs
#    a create_cmd() in its saver.batch call.
#    was     /cyber-dojo/katas/e3/T6/K2/0/event.json
#    now     /cyber-dojo/katas/e3/T6/K2/0.event.json

class Kata_v2

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    saver.exists?(id_path(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = generate_id
    manifest['version'] = 2
    event_summary = {
      'event' => 'created',
      'time' => manifest['created'],
      'index' => 0
    }
    # So you can diff against the first traffic-light.
    to_diff = {
      'files' => manifest['visible_files']
    }
    saver_assert_batch([
      manifest_write_cmd(id, json_plain(manifest)),
      events_write_cmd(id, json_plain(event_summary) + "\n"),
      event_write_cmd(id, 0, json_plain(to_diff))
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

  def ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    event_summary = {
      'colour' => colour,
      'time' => now,
      'duration' => duration,
      'index' => index
    }
    saver_assert_batch([
      events_append_cmd(id, json_plain(event_summary) + "\n"),
      event_write_cmd(id, index, json_plain(event_n))
    ])
    nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    events_src = saver.send(*events_read_cmd(id))
    saver_assert(events_src.is_a?(String))
    json_parse('[' + events_src.lines.join(',') + ']')
    # Alternative implementation, which profiling shows is slower.
    # events_src.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      events_src = saver.send(*events_read_cmd(id))
      saver_assert(events_src.is_a?(String))
      last_line = events_src.lines.last
      index = json_parse(last_line)['index']
    end
    event_src = saver.send(*event_read_cmd(id, index))
    saver_assert(event_src.is_a?(String))
    json_parse(event_src)
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
  # manifest
  #
  # In theory the manifest could store only the display_name
  # and exercise_name and be recreated, on-demand, from the relevant
  # start-point services. In practice it creates coupling, and it
  # doesn't work because start-point services change over time.

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
  # events
  #
  # A cache of colours/time-stamps for all [test] events.
  # Helps optimize dashboard traffic-lights views.
  # Each event is stored as a single "\n" terminated line.
  # This is an optimization for ran_tests() which need only
  # append to the end of the file.

  def events_write_cmd(id, event0_src)
    ['write', events_filename(id), event0_src]
  end

  def events_append_cmd(id, eventN_src)
    ['append', events_filename(id), eventN_src]
  end

  def events_read_cmd(id)
    ['read', events_filename(id)]
  end

  def events_filename(id)
    id_path(id, 'events.json')
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event

  def event_write_cmd(id, index, event_src)
    ['write', event_filename(id,index), event_src]
  end

  def event_read_cmd(id, index)
    ['read', event_filename(id,index)]
  end

  def event_filename(id, index)
    id_path(id, "#{index}.event.json")
  end

  # - - - - - - - - - - - - - -

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['katas', id[0..1], id[2..3], id[4..5]]
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

end
