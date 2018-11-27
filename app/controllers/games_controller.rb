require 'open-uri'
require 'json'
require 'pry-byebug'

class GamesController < ApplicationController
  def new
    @letters = create_array
    @start_time = Time.now
  end

  def score
    @hash_score = {}
    chompme = params[:grid].scan(/\w/)
    start_time = params[:start_time].scan(/..:..:../).join.split(':')
    end_time = (Time.now).to_s.scan(/..:..:../).join.split(':')
    @hash_score = run_game(params[:attempt], chompme, start_time, end_time)

  end

  private

  def create_array
    number = rand(5..13)
    returnarray = []
    array = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
    number.times {
      returnarray << array.sample
    }
    returnarray
  end

  def check_word_in_grid(attempt, grid)
    # comment
    var1 = true
    attempt.downcase.scan(/\w/).each do |i|
      var1 = false unless grid.join.include?(i)
    end
    if var1
      attempt.chars.all? do |letter|
        attempt.downcase.count(letter) <= grid.join.count(letter)
      end
    end
  end

  def scored(array, time)
    # comment^^^^^^^^^^^^^
    5 * array["length"].to_i / 1.1 + 50/time
  end

  def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
    start = (start_time[1].to_i * 60 + start_time[2].to_i)
    ending = (end_time[1].to_i * 60 + end_time[2].to_i)
    time = ending - start
    return { scored: 0, message: "not in the grid", time: time } unless check_word_in_grid(attempt, grid)

    url = 'https://wagon-dictionary.herokuapp.com/' + attempt
    user_serialized = open(url).read
    user = JSON.parse(user_serialized).to_h

    return { scored: 0, message: "not an english word", time: time } unless user["found"]
    # return { scored: "#{start_time[1]}:#{start_time[2]}    #{end_time[1]}:#{end_time[2]}", message: "well done", time: time }
    return { scored: scored(user, time).round(2), message: "well done", time: time }
  end
end
