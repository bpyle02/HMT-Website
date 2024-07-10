# This program can be used to decrypt an entry in the database using an id

using JSON

characters = "abcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*_-?`~/.\\" # list of accepted characters to be encrypted

# vigenere cipher algorithm adapted from https://github.com/TheAlgorithms/Julia/blob/main/src/cipher/vigenere.jl
function decrypt(text::String)
    encoded = ""
    key_index = 1 # set index to 1
    key = "green" # encryption / decryption key

    for symbol in text # loop through each symbol in the text variable
        num = findfirst(isequal(lowercase(symbol)), characters) # set num to the position of the symbol in the characters string

        if !isnothing(num) # if the value isn't found in the characters string, skip it
            num -= findfirst(isequal(key[key_index]), characters) - 1 # reverse the shifting for decryption
            num %= length(characters) # add the remainder of num / the length of the characters string to the num variable
            num = num <= 0 ? num + length(characters) : num # if num is less than or equal to 0, add the length of the characters string to it. Otherwise do noting
            encoded *= islowercase(symbol) ? characters[num] : lowercase(characters[num]) # append the character at position num to the encoded string and make sure it is lowercase
            key_index = key_index == length(key) ? 1 : key_index + 1 # increment the key index or reset it if it is at the max
        else
            encoded *= symbol # append the symbol to the encoded string
        end
    end

    return encoded # return the encoded string
end

rawJSON = JSON.parsefile("db.json"; use_mmap = false) # read JSON file

print("\nPlease enter the ID of the user you would like to decrypt: ")

UID = readline()

print("\nName: " * decrypt(rawJSON[parse(Int, UID)]["first_name"]) * " " * decrypt(rawJSON[parse(Int, UID)]["last_name"]) * "\nEmail: " * decrypt(rawJSON[parse(Int, UID)]["email"]) * "\nStatus: " * rawJSON[parse(Int, UID)]["status"] * "\n\n")
