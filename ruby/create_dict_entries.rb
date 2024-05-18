require "csv"

input_path = "tidied_colour_terms_with_RGB.csv"
tidied_data = CSV.read(input_path)

output_path = "colour_terms_dict.csv"

File.open(output_path, "w"){|f|
    #header="表層形,,,,品詞,品詞細分類1,品詞細分類2,品詞細分類3,活用型,活用形,原形,読み,発音,追加エントリ"
    #f.puts(header)
    tidied_data.each_with_index{|row, i|
        next if i == 0
        word = row[5]
        #txt = "#{word},*,*,*,名詞,一般,色彩語,*,*,*,#{word},*,*,追加エントリ"
        txt = "#{word},*,*,,名詞,一般,色彩語,*,*,*,#{word},*,*"
        f.puts(txt)
    }
}
