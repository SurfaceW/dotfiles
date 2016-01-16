# encoding: utf-8

require 'json'
require_relative 'query.rb'
require_relative 'filter_core.rb'

module SearchResults
  FILE_NAME = 'cache.search_results.json'

  def self.get
    o = Settings.default
    results = o[:cache_search_results] && get_cache
    results ||= begin
      q = Query.new
      FilterOutput.each_found_item(q, FilterOutput.output_options(q, o)).map do |item|
        [item.location, item.file_ref.file?]
      end
    end
    Cache.write(FILE_NAME, results.to_json) if o[:cache_search_results]
    results
  end

  def self.get_cache
    search_results_mtime = Cache.mtime(FILE_NAME)
    query_mtime = Cache.mtime('cache.query.txt')
    if search_results_mtime && query_mtime && search_results_mtime > query_mtime
      JSON.load(Cache.get(FILE_NAME))
    end
  end

  def self.find_next(direction, location = nil, wrap = false, items = get)
    return nil if items.empty?

    limit = if wrap
      -> i, n { wrap(i, 0, n) }
    else
      -> i, n { clamp(i, 0, n - 1) }
    end

    start_index = if location
      prev_index = items.index {|item| item[0] == location }
      if prev_index
        limit[prev_index + direction, items.size]
      else
        0
      end
    else
      0
    end

    index = start_index
    begin
      item = items[index]
      return item[0] if item[1]
      index = limit[index + direction, items.size]
    end while index != start_index

    nil
  end

  def self.wrap(v, min, max)
    if min > max
      tmp = min;
      min = max;
      max = tmp;
    end

    v -= min;

    range = max - min
    return max if range == 0

    v - (range * (v / range).floor) + min
  end

  def self.clamp(v, min, max)
    if min > max
      tmp = min;
      min = max;
      max = tmp;
    end

    return min if v < min
    return max if v > max
    v
  end
end

if __FILE__ == $0
  require_relative 'location.rb'

  args = ARGV.map {|e| e.encode('UTF-8', 'UTF8-MAC') }
  direction = (args[0] || 'next').to_sym == :prev ? -1 : 1
  if location = SearchResults.find_next(direction, Location.get, Settings.default.fetch(:wrap, true))
    require_relative 'actions.rb'
    FilterAction.navigate_to(location, false)
  end
end
