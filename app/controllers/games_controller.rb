require 'open-uri'
require 'json'
URL_DICT = "https://wagon-dictionary.herokuapp.com/"

class GamesController < ApplicationController
  def new
    @letters_array = (0...10).map { ('a'..'z').to_a[rand(26)] }
    session[:score] = 0 unless session[:score]
  end

  def score
    @letters_array = params['letters'].split("")
    @attempt = params["attempt"]
    @answer = build_answer(@attempt, @letters_array)
    session[:score] += @answer[2]
    @score = session[:score]
  end

  private

  def dict_check_word(word, url)
    url += word
    user_serialized = URI.parse(url).read
    out = JSON.parse(user_serialized)
    { found: out['found'], count: out['length'] }
  end

  def check_word_grid(grid, word)
    word.chars.all? do |letter|
      word.count(letter) <= grid.count(letter)
    end
  end

  def build_answer(word, array)
    exist = dict_check_word(@attempt, URL_DICT)
    in_grid = check_word_grid(@letters_array, @attempt)
    if exist[:found] && in_grid
      a = "Congratulations! "
      b = " is a valid English word..."
      c = exist[:count]
    elsif in_grid
      a = "Sorry, but "
      b = " does not seems to be a valid English word..."
      c = 0
    else
      a = "Sorry, but "
      b = " can't be built out of #{array.join(", ")}..."
      c = 0
    end
    [a, b, c]
  end
end
