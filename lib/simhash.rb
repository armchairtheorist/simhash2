module Simhash
  extend self

  autoload :Version, 'simhash/version'
  autoload :Stopwords, 'simhash/stopwords'

  HASHBITS = 64

  DEFAULT_OPTIONS = {
    :unique => true,
    :min_token_length => 1,
    :stop_words => false,
    :stemming => false
  }.freeze

  def generate (str, options = {})
    generate_from_tokens(str.split(' '), options)
  end

  def generate_from_tokens (tokens, options = {})
    filter_tokens(tokens, DEFAULT_OPTIONS.merge(options))

    v = [0] * HASHBITS

    masks = v.dup
    masks.each_with_index {|e, i| masks[i] = (1 << i)}

    hashes = tokens.map { |token| simple_string_hash(token, HASHBITS) }
    hashes.each do |h|
      HASHBITS.times do |i|
        v[i] += (h & masks[i]).zero? ? -1 : +1
      end
    end

    simhash = 0
    HASHBITS.times { |i| simhash += 1 << i if v[i] >= 0 }  
    
    return simhash
  end

  def hamming_distance (simhash1, simhash2)
    return (simhash1.to_i ^ simhash2.to_i).to_s(2).count("1")
  end

  private

  def simple_string_hash (str, length)
    return 0 if str == ""

    x = str.bytes.first << 7
    m = 1000003
    mask = (1<<length) - 1
    str.each_byte{ |char| x = ((x * m) ^ char.to_i) & mask }

    x ^= str.bytes.count
    x = -2 if x == -1

    return x.to_i
  end

  def filter_tokens (tokens, options)
    tokens.reject! { |e| e.nil? || e.length < options[:min_token_length] }
    tokens.map! { |e| e.downcase }
    tokens.reject!{ |e| STOPWORDS.include?(e) } if options[:stop_words]
    tokens.map!{ |e| e.stem } if options[:stemming]
    tokens.uniq! if options[:unique]
  end
end



# require 'fast-stemmer'

# def tokenize (str)
#   str.split(' ')
# end

# require 'simhash'

# str1 = "applebear hello".downcase
# str2 = "applebear applebear applebear hello".downcase
# old1 = str1.simhash
# old2 = str2.simhash
# new1 = Simhash.generate(str1)
# new2 = Simhash.generate(str2)
# puts str1
# puts str2
# puts "[#{old1.to_s(2).rjust(64)}] : [#{old2.to_s(2).rjust(64)}] : #{Simhash.hamming_distance(old1, old2)}"
# puts "[#{new1.to_s(2).rjust(64)}] : [#{new2.to_s(2).rjust(64)}] : #{Simhash.hamming_distance(new1, new2)}"
# puts

# str1 = "GOSICK ARTIST HINATA TAKEDA PASSES AWAY DUE TO AN ILLNESS".downcase
# str2 = "ILLUSTRATOR HINATA TAKEDA OF GOSICK FAME HAS PASSED AWAY".downcase
# old1 = str1.simhash
# old2 = str2.simhash
# new1 = Simhash.generate(tokenize(str1))
# new2 = Simhash.generate(tokenize(str2))
# puts str1
# puts str2
# puts "[#{old1.to_s(2).rjust(64)}] : [#{old2.to_s(2).rjust(64)}] : #{Simhash.hamming_distance(old1, old2)}"
# puts "[#{new1.to_s(2).rjust(64)}] : [#{new2.to_s(2).rjust(64)}] : #{Simhash.hamming_distance(new1, new2)}"
# puts

# str1 = "DYNASTY WARRIORS 9 IS A PS4 TITLE ADDS CENG PU".downcase
# str2 = "I like strawberry shortcake".downcase
# old1 = str1.simhash
# old2 = str2.simhash
# new1 = Simhash.generate(tokenize(str1))
# new2 = Simhash.generate(tokenize(str2))
# puts str1
# puts str2
# puts "[#{old1.to_s(2).rjust(64)}] : [#{old2.to_s(2).rjust(64)}] : #{Simhash.hamming_distance(old1, old2)}"
# puts "[#{new1.to_s(2).rjust(64)}] : [#{new2.to_s(2).rjust(64)}] : #{Simhash.hamming_distance(new1, new2)}"
# puts

# require 'benchmark'

# n = 10000
# Benchmark.bm do |x|
#   x.report { n.times do; str1.simhash; end }
#   x.report { n.times do; Simhash.generate(tokenize(str1)); end }
# end