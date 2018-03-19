require 'pry'
require 'set'

Vowels = %w(u o a e i)
Consonants = %w(y j h k c q x t d p l r s f b v w)
Alphabet = %w(u o a e i y j h k c q x t d p l r s f b v w)

class Ring
  def initialize(array=Alphabet0)
    @forward_hash = {}
    array.each_cons(2) do |pair|
      @forward_hash[pair[0]] = pair[1]
    end
    @forward_hash[array[-1]] = array[0]
    @reverse_hash = @forward_hash.invert
  end
  def next(l)
    forward_hash[l]
  end
  def previous(l)
    reverse_hash[l]
  end
  private
  attr_reader :forward_hash,:reverse_hash
end

def symbolize(array)
  array.map{|l| l.upcase.to_sym}
end

Alphabet0 = symbolize(Alphabet)
Alphabet1 = Ring.new

#


class Organism < Array

  def initialize(length=4)
    a = []
    length.times{a << Pair.new}
    super a
  end

  def parse
    Regexp.new self.map{|o| o.parse}.join
  end

  # mutations
  def deletion
    return if self.length <= 1
    self.delete_at(rand_i)
  end

  def insertion
    # self.insert(rand_i,self.sample.deep_clone)
     self.insert(rand_i,Pair.new)
  end

  def replacement
    self.sample.mutate
  end

  def mutate
    r = rand
    if (0..0.1).include? r
      deletion
    elsif (0.1..0.2).include? r
      insertion
    else
      replacement
    end
  end

  def fitness(population)
    @@random_population ||= population.map{Word.random}
    fitness = 0
    regex = self.parse
    @@random_population.each do |word|
      fitness -= 1 if regex =~ word
    end
    population.each do |word|
      fitness +=1 if regex =~ word
    end
  end

  def deep_clone
    self.map{|p| p.deep_clone}
  end

  private

  def rand_i
    rand(self.length)
  end

end


class Word < String
  class << self
  def random(length=7)
    word = self.new
    length.times {word << Alphabet.sample}
    word
  end
  end
end
#
#

class Modifier
  @@modifiers = [:"?",:"\*",:"+",nil]
  @@modifiers = @@modifiers + Array.new(30,nil)
  attr_reader :symbol
  def initialize
    @symbol = @@modifiers.sample
  end
  def mutate
    @symbol = @@modifiers.sample
  end
  def parse
    symbol.to_s
  end
  private
  attr_writer :symbol
end

class SingleCharacter
  @@ring = Alphabet1
  def initialize
    @symbol = Alphabet0.sample
  end
  attr_reader :symbol
  def mutate
    r = rand-0.5
    if r > 0
      @symbol = @@ring.next(@symbol)
    else
      @symbol = @@ring.previous(@symbol)
    end
  end
  def parse
    symbol.to_s
  end
  private
  attr_writer :symbol
end

class Group < Set
  def initialize
    a = []
    5.times do
      a << alphabet_sample
    end
    super a
  end
  def deletion
    return if self.size <= 2
    self.delete(sample)
  end
  def insertion
    self << alphabet_sample
  end

  def mutate
    r = rand-0.5
    if r > 0
      deletion
    else
      insertion
    end
  end

  def parse
    "[#{self.to_a.map{|l| l.to_s}.join}]"
  end

  def sample
    self.to_a.sample
  end
  def alphabet_sample
    Alphabet0.sample
  end
end

class Dot
  def mutate
  end
  def parse
    "."
  end
end

class Pair
  @@characters = [Dot,Group,SingleCharacter]
  attr_reader :character, :modifier
  def initialize
    @character = @@characters.sample.new
    @modifier = Modifier.new
  end

  def mutate
   character.mutate
   if rand < 0.1
   modifier.mutate
   end
  end

  def parse
    character.parse+modifier.parse
  end

  def deep_clone
    pair = self.clone
    pair.character = pair.character.clone
    pair.modifier = pair.modifier.clone
    pair
  end

  protected

  attr_accessor :character, :modifier

end



binding.pry

# @r = RegexSingle.new
