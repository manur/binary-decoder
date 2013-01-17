require 'awesome_print'
require 'csv'
load 'trie.rb'

@charToPattern = {"a"=>/^1(\d*)/, "b"=>/^10(\d*)/, "c"=>/^11(\d*)/, "d"=>/^100(\d*)/, "e"=>/^101(\d*)/, "f"=>/^110(\d*)/, "g"=>/^111(\d*)/, "h"=>/^1000(\d*)/, "i"=>/^1001(\d*)/, "j"=>/^1010(\d*)/, "k"=>/^1011(\d*)/, "l"=>/^1100(\d*)/, "m"=>/^1101(\d*)/, "n"=>/^1110(\d*)/, "o"=>/^1111(\d*)/, "p"=>/^10000(\d*)/, "q"=>/^10001(\d*)/, "r"=>/^10010(\d*)/, "s"=>/^10011(\d*)/, "t"=>/^10100(\d*)/, "u"=>/^10101(\d*)/, "v"=>/^10110(\d*)/, "w"=>/^10111(\d*)/, "x"=>/^11000(\d*)/, "y"=>/^11001(\d*)/, "z"=>/^11010(\d*)/}

@patternToChar = @charToPattern.inject({}) do |hsh, (k,v)|
  hsh[v] = k
  hsh
end

@patterns = @charToPattern.values
@code = "10001010110001000101100001001101111000011010110".split("")

@trie = Trie.new

def traverse(code, trie)
  if !code.empty?
    for char in @charToPattern.keys
      pattern = @charToPattern[char]
      if(match_obj = code.join('').match(pattern))
        puts "Matching char "+char+" with residual "+match_obj[1]+" from "+code.join('')
        trie = trie.extend(char, traverse(match_obj[1].split(""), Trie.new))
      else
        next
      end
    end

    return trie
  else
    # Mark true string conclusion
    trie.meta = true
    return trie
    # TODO
  end
end

# Ref against dictionary
words = []
File.open("/usr/share/dict/words") do |file|
  file.each do |line|
    words << line.strip
  end
end

words = words.map(&:downcase).uniq.map do |w|
  w.length > 3 ? Regexp.new(w) : nil
end.compact


@trie = traverse(@code, @trie)
CSV.open("results.csv", "wb") do |csv|

  csv << ["Decoded word", "Matching dictionary words"]

  @trie.valid_paths.each do |w|
    line = []
    line << w

    puts "Cross-referencing "+w

    matches = words.map do |dictionary_word|
      w.match(dictionary_word)
    end.compact.map do |m|
      m[0]
    end

    if !matches.empty?
      line << matches.join(' ')
      puts matches.join(' ')
    end

    csv << line.flatten
  end
end
