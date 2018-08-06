require 'time'
require 'net/http'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.sample(10)
    @start_time = Time.now
  end

  def score
    @word = params[:lw]
    @letters = params[:letters]
    @time = Time.now - Time.parse(params[:start_time])
    if included?(@word, @letters)
      if english_word?(@word)
          score = compute_score(@word, @time)
          @result = [score.round, "well done"]
          session[:cumul_score].nil? ? session[:cumul_score] = score.round : session[:cumul_score] += score.round
        else
        @result = [0, "not an english word"]
      end
    else
      @result= [0, "not in the grid"]
    end
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    uri = URI("https://wagon-dictionary.herokuapp.com/#{word}")
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
    json["found"]
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end
end
