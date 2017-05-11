module Simhash
  autoload :Version, 'simhash/version'

  def generate (tokens)
    v = [0] * 64

    masks = v.dup
    masks.each_with_index {|e, i| masks[i] = (1 << i)}

    hashes = tokens.map { |token| token.hash_str.to_i }
    hashes.each do |h|

      64.times do |i|
        v[i] += (h & masks[i]).zero? ? -1 : +1
      end
    end

  fingerprint = 0
  64.times { |i| fingerprint += 1 << i if v[i] >= 0 }  
  fingerprint    

  end


end







STOP_WORDS = IO.readlines(File.dirname(__FILE__) + "/lib/newsmaki/helpers/stopwords.txt")
    .map { |x| x.strip }
    .delete_if { |x| x.empty? || x.start_with?('#') }
    .freeze

module Stopwords
    EN = " a able about above abst accordance according accordingly across act actually added adj adopted affected affecting affects after afterwards again against ah all almost alone along already also although always am among amongst an and announce another any anybody anyhow anymore anyone anything anyway anyways anywhere apparently approximately are aren arent arise around as aside ask asking at auth available away awfully b back be became because become becomes becoming been before beforehand begin beginning beginnings begins behind being believe below beside besides between beyond biol both brief briefly but by c ca came can cannot can't cause causes certain certainly co com come comes contain containing contains could couldnt d date did didn't different do does doesn't doing done don't down downwards due during e each ed edu effect eg eight eighty either else elsewhere end ending enough especially et et-al etc even ever every everybody everyone everything everywhere ex except f far few ff fifth first five fix followed following follows for former formerly forth found four from further furthermore g gave get gets getting give given gives giving go goes gone got gotten h had happens hardly has hasn't have haven't having he hed hence her here hereafter hereby herein heres hereupon hers herself hes hi hid him himself his hither home how howbeit however hundred i id ie if i'll im immediate immediately importance important in inc indeed index information instead into invention inward is isn't it itd it'll its itself i've j just k keep keeps kept keys kg km know known knows l largely last lately later latter latterly least less lest let lets like liked likely line little 'll look looking looks ltd m made mainly make makes many may maybe me mean means meantime meanwhile merely mg might million miss ml more moreover most mostly mr mrs much mug must my myself n na name namely nay nd near nearly necessarily necessary need needs neither never nevertheless new next nine ninety no nobody non none nonetheless noone nor normally nos not noted nothing now nowhere o obtain obtained obviously of off often oh ok okay old omitted on once one ones only onto or ord other others otherwise ought our ours ourselves out outside over overall owing own p page pages part particular particularly past per perhaps placed please plus poorly possible possibly potentially pp predominantly present previously primarily probably promptly proud provides put q que quickly quite qv r ran rather rd re readily really recent recently ref refs regarding regardless regards related relatively research respectively resulted resulting results right run s said same saw say saying says sec section see seeing seem seemed seeming seems seen self selves sent seven several shall she shed she'll shes should shouldn't show showed shown showns shows significant significantly similar similarly since six slightly so some somebody somehow someone somethan something sometime sometimes somewhat somewhere soon sorry specifically specified specify specifying state states still stop strongly sub substantially successfully such sufficiently suggest sup sure t take taken taking tell tends th than thank thanks thanx that that'll thats that've the their theirs them themselves then thence there thereafter thereby thered therefore therein there'll thereof therere theres thereto thereupon there've these they theyd they'll theyre they've think this those thou though thoughh thousand throug through throughout thru thus til tip to together too took toward towards tried tries truly try trying ts twice two u un under unfortunately unless unlike unlikely until unto up upon ups us use used useful usefully usefulness uses using usually v value various 've very via viz vol vols vs w want wants was wasn't way we wed welcome we'll went were weren't we've what whatever what'll whats when whence whenever where whereafter whereas whereby wherein wheres whereupon wherever whether which while whim whither who whod whoever whole who'll whom whomever whos whose why widely willing wish with within without won't words world would wouldn't www x y yes yet you youd you'll your youre yours yourself yourselves you've z zero "
  end

  def shingles (str)
    str.split(//).each_cons(2).inject([]) { |a, c| a << c.join }.uniq
  end

require 'fast-stemmer'
require 'digest/sha1'

def tokenize (str)
  x = str.split(' ')
  x.reject!{ |w| STOP_WORDS.include?(w) }
  # x.reject!{ |w| Stopwords::EN.index(" #{w} ") != nil }
   x.map! { |word| word.stem }
   x.uniq!
  
 

  # x = shingles(x.join)
 # shingles str
 
 # puts x
  x
end

class String
  def hash_str(length = 64)
    return 0 if self == ""

    x = self.bytes.first << 7
    m = 1000003
    mask = (1<<length) - 1
    self.each_byte{ |char| x = ((x * m) ^ char.to_i) & mask }

    x ^= self.bytes.count
    x = -2 if x == -1
    x
     # Digest::SHA1.hexdigest(self).to_i(16)
  end
end

def simhash2 (tokens)
  v = [0] * 64

  masks = v.dup
  masks.each_with_index {|e, i| masks[i] = (1 << i)}

  hashes = tokens.map { |token| token.hash_str.to_i }
  hashes.each do |h|
    # h.to_s(2).split(//).each_with_index do |bit, i|
    #   bit.to_i & 1 == 1 ? v[i] += 1 : v[i] -= 1
    # end

    64.times do |i|
      v[i] += (h & masks[i]).zero? ? -1 : +1
    end
  end
  # v.map{ |i| i >= 0 ? 1 : 0 }.join.to_i(2)

  fingerprint = 0
  64.times { |i| fingerprint += 1 << i if v[i] >= 0 }  
  fingerprint    
end

def calculate_hamming_distance (simhash1, simhash2)
  return (simhash1.to_i ^ simhash2.to_i).to_s(2).count("1")
end



require 'simhash'


str1 = "GOSICK ARTIST HINATA TAKEDA PASSED AWAY".downcase
str2 = "GOSICK ILLUSTRATOR HINATA TAKEDA PASSES AWAY".downcase
# str1 = "I love dogs"
# str2 = "I love cats"
old1 = str1.simhash(stop_words: true)
old2 = str2.simhash(stop_words: true)
new1 = simhash2(tokenize(str1))
new2 = simhash2(tokenize(str2))
puts "[#{old1.to_s(2).rjust(64)}] : [#{old2.to_s(2).rjust(64)}] : #{calculate_hamming_distance(old1, old2)}"
puts "[#{new1.to_s(2).rjust(64)}] : [#{new2.to_s(2).rjust(64)}] : #{calculate_hamming_distance(new1, new2)}"

puts tokenize(str1).join (' ')
puts tokenize(str2).join (' ')


puts
str1 = "GOSICK ARTIST HINATA TAKEDA PASSES AWAY DUE TO AN ILLNESS".downcase
str2 = "ILLUSTRATOR HINATA TAKEDA OF GOSICK FAME HAS PASSED AWAY".downcase
old1 = str1.simhash
old2 = str2.simhash
new1 = simhash2(tokenize(str1))
new2 = simhash2(tokenize(str2))
puts "[#{old1.to_s(2).rjust(64)}] : [#{old2.to_s(2).rjust(64)}] : #{calculate_hamming_distance(old1, old2)}"
puts "[#{new1.to_s(2).rjust(64)}] : [#{new2.to_s(2).rjust(64)}] : #{calculate_hamming_distance(new1, new2)}"

puts tokenize(str1).join (' ')
puts tokenize(str2).join (' ')



puts
str1 = "DYNASTY WARRIORS 9 IS A PS4 TITLE ADDS CENG PU".downcase
str2 = "MOJAVE WARRIORS 10 IS A TERRIBLE GAME".downcase
old1 = str1.simhash
old2 = str2.simhash
new1 = simhash2(tokenize(str1))
new2 = simhash2(tokenize(str2))
puts "[#{old1.to_s(2).rjust(64)}] : [#{old2.to_s(2).rjust(64)}] : #{calculate_hamming_distance(old1, old2)}"
puts "[#{new1.to_s(2).rjust(64)}] : [#{new2.to_s(2).rjust(64)}] : #{calculate_hamming_distance(new1, new2)}"

puts tokenize(str1).join (' ')
puts tokenize(str2).join (' ')

require 'benchmark'



n = 10000
Benchmark.bm do |x|
  x.report { n.times do; str1.simhash; end }
  x.report { n.times do; simhash2(tokenize(str1)); end }
end