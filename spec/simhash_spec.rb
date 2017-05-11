require 'spec_helper'

describe Simhash do
  it 'should generate the same simhash for the same string, and a different simhash for a different string' do
    str1 = "I like going to the beach"
    str2 = "I like going to the beach"
    str3 = "I like going to the mall"

    expect(Simhash.generate(str1)).to eq Simhash.generate(str2)
    expect(Simhash.generate(str1)).not_to eq Simhash.generate(str3)
  end

  it 'should respect the :unique option' do
    str1 = "apple pear"
    str2 = "apple apple apple pear"

    expect(Simhash.generate(str1, unique: true)).to eq Simhash.generate(str2, unique: true)
    expect(Simhash.generate(str1, unique: false)).not_to eq Simhash.generate(str2, unique: false)
  end

  it 'should calculate hamming distances correctly' do
    expect(Simhash.hamming_distance(2, 2)).to eq 0
    expect(Simhash.hamming_distance(2, 3)).to eq 1
    expect(Simhash.hamming_distance(255, 197)).to eq 4
  end
end