class Maker
  attr_accessor :secret, :positions, :upper_char

  def initialize
    @secret = []
    @positions = 4
    @upper_char = 'f'
  end

  def change_maker_level(positions, u_char)
    @positions = positions
    @upper_char = u_char
  end

  def make_code
    i = 0
    while i < @positions
      secret << (rand(('a'.ord)..(@upper_char.ord))).chr
      i += 1
    end
    # Printing Secret
    puts "Secret: #{@secret}"
    @secret
  end

  def give_feedback(guess)
    feedback_list = []
    secret = @secret.dup
    index = 0
    # Check for x's
    while index < guess.count
      if guess[index] == secret[index]
        secret.delete_at(index)
        guess.delete_at(index)
        feedback_list << 'x'
      else
        index += 1
        # Check for o's
      end
    end
    index = 0
    while index < guess.count
      letter = guess[index]
      if secret.include?(letter)
        secret.delete_at(secret.index(letter))
        guess.delete_at(index)
        feedback_list << 'o'
      else
        index += 1
        feedback_list << ' '
      end
    end
    feedback_list
  end
end

class Breaker
  attr_accessor :guess_length

  def initialize
    @guess_length = 4
  end

  def guess(u_char)
    invalid = true
    user_guess = ''
    while invalid
      puts 'Enter your guess: '
      user_guess = gets.chomp
      if user_guess.length != @guess_length
        next
      end
      user_guess.each_char do |item|
        if item >= 'a' && item <= u_char
          invalid = false
          break
        else
          next
        end
      end
    end
    user_guess
  end
end

class Board
  attr_accessor :num_rows, :board_list, :shift

  def initialize
    @num_rows = 13
    @board_list = []
    @shift = 10
  end

  def make_turn(feedback, guess)
    @board_list << {guess: guess, feedback: feedback}
  end

  def future_board
    next_board = ''
    (turn_number..@num_rows).each do |i|
      next_board += "\n{" + ' ' * @shift + "} |       |  #{i}"
    end
    next_board
  end

  def complete_board
    curr_board + future_board
  end

  def turn_number
    @board_list.count
  end

  def curr_board
    current_board = ''
    i = 0
    while i < turn_number
      current_board += "\n{#{(board_list[i][:feedback]).join('  ')}} |#{(board_list[i][:guess].join(' '))}|  #{i}"
      i += 1
    end
    current_board
  end

  def determine_state(maker)
    if board_list.count >= 1 && board_list[-1][:feedback].count('x') == maker.positions
      'breaker wins'
    elsif future_board.empty?
      return 'maker wins'
    else
      'in progress'
    end
  end
end

def game_engine
  maker = Maker.new
  breaker = Breaker.new
  board = Board.new
  # Difficulty level
  puts 'Shall I make it: (e)asy, (m)oderate, or (h)ard: '
  level = gets.chomp
  puts "\nRules:"
  puts 'x = correct letter in the correct position'
  puts 'o = correct letter in the incorrect position'
  if level == 'e'
    board.num_rows = 14
    maker.change_maker_level(4, 'f')
    puts 'Guess letters between a and f, inclusive.'
  elsif level == 'm'
    board.num_rows = 12
    maker.change_maker_level(4, 'f')
    puts 'Guess letters between a and f, inclusive.'
  elsif level == 'h'
    board.num_rows = 12
    board.shift = 13
    maker.change_maker_level(5, 'g')
    puts 'Guess letters between a and g, inclusive.'
    breaker.guess_length = 5
  end


#The actual game play
  maker.make_code
  while board.determine_state(maker) == 'in progress'
    puts board.complete_board
    # guess in an array
    guess = breaker.guess(maker.upper_char).split(//)
    feedback = maker.give_feedback(guess.dup).sort!.reverse!
    board.make_turn(feedback, guess)
  end
# Game over
  puts board.complete_board
  if board.determine_state(maker) == 'breaker wins'
    puts 'The code breaker wins!'
  elsif board.determine_state(maker) == 'maker wins'
    puts 'The code maker wins!'
    puts "The code was #{maker.secret}"
  end
end

game_engine()