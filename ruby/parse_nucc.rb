module MeCabEditor
    require "natto"

    def clean_parsed_results(parsed)
        parsed.split("\n").map{|row|
            next if row == "EOS"
            key = row.split("\t")[0]
            pos = row.split("\t")[1]
            {key => pos.split(",")}
        }.compact
    end
end

class ParseTerms
    require "csv"

    include MeCabEditor

    def initialize
      @mecab_parser = Natto::MeCab.new
      @terms = []
      @parsed_terms = {}
      read_terms
    end

    def read_terms
        tidied_terms_csv = CSV.read("tidied_colour_terms_with_RGB.csv")
        @terms.push(tidied_terms_csv.map{|row| row[5]}).flatten!.uniq!
        parse_terms
    end

    def parse_terms
        @terms.each_with_index{|term, i|
            @parsed_terms[term] = clean_parsed_results(@mecab_parser.parse(term)) if i > 0
        }
    end

    def get_parsed_terms
        return @parsed_terms
    end
end

class ParseNucc
  require "csv"
  include MeCabEditor

  def initialize(parsed_terms)
    #パーサーと色彩語のリスト
    @mecab_parser = Natto::MeCab.new
    @parsed_terms = parsed_terms
    @tidied_results = convert_freq(get_result_csv)

    #検索用データの取得
    @all_terms = []
    @first_terms = []
    @first_simplex_words = []
    @first_complex_words = []
    @frequent_first_words = []
    @first_complex_words_hash = {}

    #コーパス上での色彩語の配列
    @result_array = []

    #処理
    get_term_array
    parse_folder
    add_count_to_freq_table
    print_result
  end

  def get_result_csv
      CSV.read("tidied_colour_terms_with_RGB.csv")
  end

  def convert_freq(result_table)
      result_table.each_with_index{|row, i| row[6] = 0 if i > 0}
  end

  def get_term_array
      (2..5).to_a.each{|i| @first_complex_words_hash[i] = []}

      @parsed_terms.each{|key, pos|
          @all_terms.push(key)
          first_word = pos[0].keys.first
          @first_terms.push(first_word)
          if pos.length > 1
              @first_complex_words.push(first_word)
              @first_complex_words_hash[pos.length].push(pos.map{|parsed| parsed.keys.first})
          else
              @first_simplex_words.push(first_word)
          end
      }

      @frequent_first_words.push((@first_complex_words and @first_simplex_words).compact).flatten!.uniq!
  end

  def parse_folder
    dir_name = "nucc"
    corpus_path_array = []
    # ファイル名の取得
    Dir.glob("#{dir_name}/*"){|item| corpus_path_array.push(item)}

    corpus_path_array.each_with_index{|file_path| parse_text(file_path)}
  end

  def parse_text(path)
    File.open(path){|f|
        f.each_line{|line| search_target(line) }
    }
    p @result_array.tally
  end

  def search_target(line)
    parsed_sentence = @mecab_parser.parse(line).split("\n")

    parsed_sentence.each_with_index{|parsed_unit, i|
      splitted_parsed_unit = parsed_unit.split(/\t/)
      word = splitted_parsed_unit[0]

      next if splitted_parsed_unit.size == 1 or !@first_terms.include?(word)

      inspect_word(splitted_parsed_unit, parsed_sentence, i)
    }
  end

  def inspect_word(splitted_parsed_unit, parsed_sentence, i)
      range = (1..4).to_a
      word = splitted_parsed_unit[0]
      candidate_array = []
      range.each{|j|
          compound = [word]
          j.times{|k|
              candidate = parsed_sentence[k].nil? ? nil : parsed_sentence[k].split(/\t/)[0]
              compound.push(candidate)
          }
          candidate_array.push(compound)
      }
      selected = candidate_array.select{|candidate_array| @all_terms.include?(candidate_array.join)}
      if selected.length == 0
          @result_array.push(word) if is_a_simplex_term(word)
      else
          @result_array.push(selected.join)
      end
  end

  def is_a_simplex_term(word)
      @first_simplex_words.include?(word)
  end

  def add_count_to_freq_table
      freq_hash = @result_array.tally
      @tidied_results.each_with_index{|row, i|
          freq = freq_hash[row[5]]
          row[6] = freq unless freq.nil?
      }
      print_result
  end

  def print_result(output_path = "nucc_colour_terms.csv")
      File.open(output_path, "w"){|f|
          @tidied_results.each{|row| f.puts(row.join(","))}
      }
  end

end

parsed_terms = ParseTerms.new.get_parsed_terms
ParseNucc.new(parsed_terms)
