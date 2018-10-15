require_relative 'simhash2/version'

module Simhash
  extend self

  HASHBITS = 64

  OPTIONS = {
    min_token_length: 1,
    unique: false,
    stemming: false,
    stop_words: []
  }.freeze

  def similarity(string1, string2, options = {})
    return hash_similarity(generate(string1, options), generate(string2, options))
  end

  def generate(str, options = {})
    generate_from_tokens(str.split(/\s+/), options)
  end

  def generate_from_tokens(tokens, options = {})
    filter_tokens(tokens, OPTIONS.merge(options))

    v = [0] * HASHBITS

    masks = v.dup
    masks.each_with_index { |_e, i| masks[i] = (1 << i) }

    hashes = tokens.map { |token| simple_string_hash(token, HASHBITS) }
    hashes.each do |h|
      HASHBITS.times do |i|
        v[i] += (h & masks[i]).zero? ? -1 : +1
      end
    end

    simhash = 0
    HASHBITS.times { |i| simhash += 1 << i if v[i] >= 0 }

    simhash
  end

  def hamming_distance(simhash1, simhash2)
    (simhash1.to_i ^ simhash2.to_i).to_s(2).count('1')
  end

  def hash_similarity(left, right)
    return (1.0 - (hamming_distance(left, right).to_f / HASHBITS))
  end

  private

  def simple_string_hash(str, length)
    return 0 if str == ''

    x = str.bytes.first << 7
    m = 1_000_003
    mask = (1 << length) - 1
    str.each_byte { |char| x = ((x * m) ^ char.to_i) & mask }

    x ^= str.bytes.count
    x = -2 if x == -1

    x.to_i
  end

  def filter_tokens(tokens, options)
    tokens.map! { |e| e.downcase.gsub(/\W+/, '') }
    tokens.reject! { |e| e.nil? || e.length < options[:min_token_length] }
    tokens.reject! { |e| options[:stop_words].include?(e) } unless options[:stop_words].nil? || options[:stop_words].empty?
    tokens.map!(&:stem) if options[:stemming]
    tokens.uniq! if options[:unique]
  end

end
