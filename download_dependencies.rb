require 'open-uri'

NNUE_NAME_BIG  = "nn-1111cefa1111.nnue"
NNUE_NAME_SMALL = "nn-37f18f62d772.nnue"

puts "Downloading big NNUE file"
URI.open("https://tests.stockfishchess.org/api/nn/#{NNUE_NAME_BIG}") do |remote_nnue|
    download_destination = File.join(__dir__, NNUE_NAME_BIG)
    File.open(download_destination, "wb") do |local_nnue|
    local_nnue.write(remote_nnue.read)
    end
end


puts "Downloading small NNUE file"
URI.open("https://tests.stockfishchess.org/api/nn/#{NNUE_NAME_SMALL}") do |remote_nnue|
    download_destination = File.join(__dir__, NNUE_NAME_SMALL)
    File.open(download_destination, "wb") do |local_nnue|
    local_nnue.write(remote_nnue.read)
    end
end