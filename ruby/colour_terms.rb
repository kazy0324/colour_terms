require "csv"

raw_dat_path = "wikipedia_colour_terms_with_RGB.csv"
tidied_csv_path = "tidied_colour_terms_with_RGB.csv"

raw_dat = CSV.read(raw_dat_path)

colour_terms_hash = {}

raw_dat.each_with_index{|row, i|
    next if i == 0
    hex_code = row[0]
    r_code = row[1]
    g_code = row[2]
    b_code = row[3]
    next if [r_code, g_code, b_code].join.length == 0
    yomi = row[4].split("・").map{|txt|
        edited = txt.gsub("JIS", "")
        edited.match?(/^[ぁ-ん]+$/) ? nil : edited
    }
    #next if yomi.nil?
    jp_en_term = row[5].split("・")
    synonyms = row[6].nil? ? nil : row[6].split("・")
    terms = [yomi, jp_en_term, synonyms].compact.flatten
    #terms_array.push(terms).flatten
    colour_terms_hash[hex_code] = {
        :r_code => r_code,
        :g_code => g_code,
        :b_code => b_code,
        :terms => terms,
        :freq => 0
    }
}

File.open(tidied_csv_path, "w"){|f|
    header = [
        "id", "hex_code", "R", "G", "B", "term", "freq"
    ]
    f.puts(header.join(","))

    id = 1
    colour_terms_hash.each{|hex_code, val|
        val[:terms].each{|term|
            next if term.nil?
            row = [
                id,
                hex_code,
                val[:r_code],
                val[:g_code],
                val[:b_code],
                term,
                val[:freq]
            ]
            f.puts(row.join(","))
            id += 1
        }
    }
}

puts "DONE!!"
