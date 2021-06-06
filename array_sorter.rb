arizona_only_6_5_2021 = 'data/zips/arizona_master_zips_only_6_5_2021.txt'

@zip_codes = File.readlines(arizona_only_6_5_2021)
@sorted = @zip_codes.sort

File.open(arizona_only_6_5_2021, 'w') { |file| file.puts @sorted }

