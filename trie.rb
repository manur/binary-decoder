class Trie

  ALPHABET = %w{a b c d e f g h i j k l m n o p q r s t u v w x y z}
  ALPHABET.each do |letter|
    attr_accessor letter.to_sym
  end

  attr_accessor :meta

  def extend(letter, trie=nil)
    t = trie || self.get(letter) || Trie.new
    self.send((letter+"=").to_sym, t)
    return self
  end

  def get(letter)
    self.send(letter)
  end

  def letters
    Trie::ALPHABET.select do |letter|
      self.get(letter)
    end
  end

  def children
    Trie::ALPHABET.map do |letter|
      {letter => self.get(letter)}
    end.inject(&:merge)
  end

  def expansion
    self.letters do |letter|
      (t = self.get(letter)) ? [letter, t.expansion] : nil
    end.compact
  end

  def empty?
    Trie::ALPHABET.all? do |letter|
      self.get(letter).nil?
    end
  end

  def paths
    if self.empty?
      if self.meta
        return ['']
      else
        return ['---']
      end
    else
      v = self.letters.map do |l|
        rest = self.get(l).paths
        rest.map do |ll|
          l + ll
        end
      end.flatten
      return v
    end
  end

  def valid_paths
    paths.reject do |p|
       p =~ /---$/
    end
  end

  def push(str)
    unless str.empty?
      chars = str.split("")
      self.extend(chars.first)
      self.get(chars.first).push(chars[1..-1].join(''))
    else
      # TODO
    end
    self
  end


end
