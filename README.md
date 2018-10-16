[![Gem Version](https://badge.fury.io/rb/simhash2.svg)](https://badge.fury.io/rb/simhash2)
[![Code Climate](https://codeclimate.com/github/armchairtheorist/simhash2/badges/gpa.svg)](https://codeclimate.com/github/armchairtheorist/simhash2)
[![Build Status](https://travis-ci.org/armchairtheorist/simhash2.svg?branch=master)](https://travis-ci.org/armchairtheorist/simhash2)
[![Coverage Status](https://coveralls.io/repos/github/armchairtheorist/simhash2/badge.svg?branch=master)](https://coveralls.io/github/armchairtheorist/simhash2?branch=master)

# Simhash2

**Simhash2** is a rewrite of the [bookmate/simhash](https://github.com/bookmate/simhash) gem, which is an implementation of Moses Charikar's simhashes in Ruby. The key differences are that this gem doesn't monkey patch the `String` and `Integer`, and configuration is also slightly easier. The simhash values generated by this gem on a default configuration should be identical to what is generated by the Bookmate version.

## Installation

Install the gem from RubyGems:

```bash
gem install simhash2
```

If you use Bundler, just add it to your Gemfile and run `bundle install`

```ruby
gem 'simhash2'
```

I have only tested this gem on Ruby 2.4.1, but there shouldn't be any reason why it wouldn't work on earlier Ruby versions as well.

## Usage

```ruby
str1 = "I am the king of the world!"
str2 = "I am the queen of the world!"

simhash1 = Simhash.generate(str1) # => 86798109229625320
simhash2 = Simhash.generate(str2) # => 13921220612431195624

Simhash.hamming_distance(simhash1, simhash2) # => 8
```

## Performance

Thanks to some performance optimizations by [JayTeeSF](https://github.com/JayTeeSF), this gem generally performs better than `bookmate\simhash`, especially when working with longer strings with lots of tokens.

```ruby
test_str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

def test_simhash (x)
  x.simhash # bookmate/simhash
end

def test_simhash2 (x)
  Simhash.generate(x) # this gem
end

n = 5000
Benchmark.bm do |x|
  x.report("simhash") { for i in 1..n; test_simhash(test_str); end }
  x.report("simhash2") { for i in 1..n; test_simhash2(test_str); end }
end
```

Results:

```
       user     system      total        real
simhash  5.109375   0.093750   5.203125 (  5.199069)
simhash2  4.109375   0.000000   4.109375 (  4.108586)
```
