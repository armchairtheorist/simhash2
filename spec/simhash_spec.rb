require 'simhash2'
require 'fast-stemmer'

describe Simhash do
  it 'should generate the same simhash for the same string, and a different simhash for a different string' do
    str1 = 'I like going to the beach'
    str2 = 'I like going to the beach'
    str3 = 'I like going to the mall'

    expect(Simhash.generate(str1)).to eq Simhash.generate(str2)
    expect(Simhash.generate(str1)).not_to eq Simhash.generate(str3)
  end

  it 'should calculate the same similarity for the same string, and a lower similarity for a different string' do
    str1 = 'I like going to the beach'
    str2 = 'I like going to the beach'
    str3 = 'I like going to the mall'

    expect(Simhash.similarity(str1, str2)).to eq 1.0
    expect(Simhash.similarity(str1, str3)).to be < 1.0
  end

  it 'should strip punctuation and capitalization properly' do
    str1 = "Hello, nurse!  How's it going today...   my man?"
    str2 = 'hello nurse hows it going today my man'

    expect(Simhash.generate(str1, unique: true)).to eq Simhash.generate(str2, unique: true)
  end

  it "should respect the 'unique' option" do
    str1 = 'apple pear'
    str2 = 'apple apple apple pear'

    expect(Simhash.generate(str1, unique: true)).to eq Simhash.generate(str2, unique: true)
    expect(Simhash.generate(str1, unique: false)).not_to eq Simhash.generate(str2, unique: false)
  end

  it "should respect the 'stop_words' option" do
    str1 = 'I like the man on the moon.'
    str2 = 'like man moon'
    stop_words = %w[i the on]

    expect(Simhash.generate(str1, stop_words: stop_words)).to eq Simhash.generate(str2, stop_words: stop_words)
    expect(Simhash.generate(str1)).not_to eq Simhash.generate(str2)
  end

  it "should respect the 'stemming' option" do
    str1 = 'My crazy cars have crazy minds!'
    str2 = 'My crazi car have crazi mind!'

    expect(Simhash.generate(str1, stemming: true)).to eq Simhash.generate(str2, stemming: true)
    expect(Simhash.generate(str1, stemming: false)).not_to eq Simhash.generate(str2, stemming: false)
  end

  it 'should calculate hamming distances correctly' do
    expect(Simhash.hamming_distance(2, 2)).to eq 0
    expect(Simhash.hamming_distance(2, 3)).to eq 1
    expect(Simhash.hamming_distance(255, 197)).to eq 4
  end
end
