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
    # the split is how we get our tokens (or shingles)
    # adjust that, if we want to use shingles
    generate_from_tokens(str.split(/\s+/), options)
  end

  def generate_from_tokens(tokens, options = {})
    v = [0] * HASHBITS
    masks = v.dup
    masks.each_with_index { |_e, i| masks[i] = (1 << i) }

    filter_tokens(tokens, OPTIONS.merge(options)) do |token|
      h = simple_string_hash(token, HASHBITS)
      #warn "simple_string_hash (for: #{token.inspect}): #{h.inspect}"

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

  def filter_tokens(tokens, options, &block)
    altered_tokens = []
    tokens.each do |e|
      new_e = e.downcase.gsub(/\W+/, '')
      next if new_e.nil? || new_e.length < options[:min_token_length]
      if options[:stop_words] && !options[:stop_words].empty?
        next if options[:stop_words].include?(new_e)
      end
      if options[:stemming]
        altered_tokens << new_e.stem
      else
        altered_tokens << new_e
      end
    end
    altered_tokens.uniq! if options[:unique]

    if block_given?
      altered_tokens.each {|e| block[e] }
    else
      tokens.clear
      altered_tokens.each {|e| tokens << e }
      tokens
    end
  end
end
