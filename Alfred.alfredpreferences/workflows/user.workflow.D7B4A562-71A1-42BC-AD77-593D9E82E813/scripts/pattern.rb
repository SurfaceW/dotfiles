# encoding: utf-8

class Pattern
  attr_reader :re, :inverted
  def initialize(re, inverted, targets)
    @re = re
    @inverted = inverted
    @targets = targets
  end

  def match?(other)
    unless @inverted
      other =~ @re
    else
      other !~ @re
    end
  end

  def match_any?(a)
    unless @inverted
      a.any? {|e| e =~ @re }
    else
      a.all? {|e| e !~ @re }
    end
  end

  def target?(key)
    @targets.key?(key)
  end

  def single_target?(key)
    @targets.key?(key) && @targets.size == 1
  end

  def one_of_targets?(key)
    @targets.key?(key) && @targets.size != 1
  end

  def value_for_target(key)
    @targets[key]
  end

  def num_targets
    @targets.size
  end

  def empty_targets?
    @targets.empty?
  end

  def type_of_target(key)
    if @targets.key?(key)
      @targets.size == 1 ? :only_one : :member
    else
      :non_member
    end
  end

  def except(*keys)
    targets = @targets.dup
    keys.each { |key| targets.delete(key) }
    Pattern.new(@re, @inverted, targets)
  end

  def inspect
    @@kv_to_mod ||= MOD_TO_KV.invert

    mod = ''
    [:name, :tags, :grep].each do |k|
      mod << @@kv_to_mod[[k, @targets[k]]] if @targets.key?(k)
    end
    mod << '!' if @inverted
    '(' + @re.inspect + (mod.empty? ? '' : ' -' + mod) + ')'
  end

  MOD_TO_KV = {
    'x' => [:name, :extname],
    'b' => [:name, :basename],
    'n' => [:name, :filename],
    'p' => [:name, :pathname],
    't' => [:tags, true],
    'c' => [:grep, :any],
    'g' => [:grep, :all]
  }
end

module Patterns
  def self.any_target?(patterns, key)
    patterns.any? {|p| p.target?(key) }
  end

  def self.group(patterns, key)
    g = patterns.group_by {|p| p.type_of_target(key) }
    [g[:only_one] || [], g[:member] || [], g[:non_member] || []]
  end

  def self.test(patterns, key, &block)
    return [] if patterns.empty?
    test_by_group(key, *Patterns.group(patterns, key), &block)
  end

  def self.test_by_group(key, simple, possible, defferd)
    unless simple.all? {|p| yield(p) }
      return nil
    end

    possible.each do |p|
      unless yield(p)
        defferd << p.except(key)
      end
    end

    defferd
  end

  def self.except(patterns, *keys)
    results = []
    patterns.each do |p|
      p = p.except(*keys)
      results << p unless p.empty_targets?
    end
    results
  end
end
