BLACK = "\u25CB".encode('utf-8')
WHITE = "\u25CF".encode('utf-8')
EMPTY = '_'

class Game
  def initialize()
    @current_turn = WHITE
    @grid = []
    6.times { @grid.push ( Array.new(7) { EMPTY } ) }
  end

  def play
    puts "Select player 1 color (white or black)"
    input = gets.chomp.downcase
    color = { 
      "black" => BLACK, "b" => BLACK, "2" => BLACK,
      "white" => WHITE, "w" => WHITE, "1" => WHITE
    }
    until color[input] do
      puts "Insert a valid input"
      input = gets.chomp.downcase
    end
    @current_turn = color[input]
    
    gameplay_loop
  end

  def valid_play?(column)
    @grid[0][column] == EMPTY
  end

  def place_color(column, color)
    return false unless valid_play?(column)
    (@grid.size - 1).downto(0) do |i|
      return @grid[i][column] = color if @grid[i][column] == EMPTY
    end
  end

  def game_over?
    @grid.each do |row|
      in_a_row = 1
      previus_column = EMPTY
      row.each do |column|
        column == previus_column && column != EMPTY ? in_a_row += 1 : in_a_row = 1
        return true if in_a_row == 4
        previus_column = column
      end
    end

    for i in (0...@grid.first.size) do
      consecutives = 1
      previus_row = EMPTY
      get_column(i).each do |row|
        row == previus_row && row != EMPTY ? consecutives += 1 : consecutives = 1
        return true if consecutives == 4
        previus_row = row
      end
    end

    get_diagonals.each do |arr|
      diagonal_consecutive = 1
      previous_cell = EMPTY
      for xy in arr do
        @grid[xy.first][xy.last] == previous_cell && !empty_cell?(xy.first, xy.last) ? diagonal_consecutive += 1 : diagonal_consecutive = 1
        return true if diagonal_consecutive == 4
        previous_cell = @grid[xy.first][xy.last]
      end
    end
    false
  end
  
  def player_turn
    puts "Select a position to play (1-7) #{@current_turn}"
    input = valid_input
    valid = place_color(input, @current_turn)
    until valid do
      puts "Select another position to play (1-7)"
      input = valid_input
      valid = place_color(input, @current_turn)
    end
  end

  def next_turn
    case @current_turn
    when WHITE then @current_turn = BLACK
    when BLACK then @current_turn = WHITE
    end
  end
  
  def empty_cell?(row, column)
    @grid[row][column] == EMPTY
  end
  
  def get_column(column)
    @grid.map { |row| row[column] }
  end
  
  def draw()
    6.times do |r| 
      7.times { |c| print @grid[r][c], ' ' }
      puts ""
    end
  end
  
  private
  def valid_input
    input = gets.chomp
    until (1..7).include?input.to_i do
      puts 'invalid play, select a number between 1 and 7'
      input = gets.chomp
    end
    input.to_i - 1
  end

  def gameplay_loop
    until over = game_over? do
      player_turn
      next_turn
      draw
      # sleep(0.5)
    end
    puts "The winner is #{next_turn}"
    true
  end

  def get_diagonals
    diagonals = []
    for row in (0...6) do
      for column in (0...7) do
        diagonal = []
        4.times do |offset|
          if (row + offset).between?(0, 5) && (column + offset).between?(0, 6)
            diagonal.push [row + offset, column + offset] 
          end
        end
        diagonals << diagonal if diagonal.size == 4
        
        diagonal = []
        4.times do |offset| 
          if (row + offset).between?(0, 5) && (column - offset).between?(0, 6)
            diagonal.push [row + offset, column - offset] 
          end
        end
        diagonals << diagonal if diagonal.size == 4
      end
    end
    diagonals
  end
end

# Uncomment to play

# game = Game.new
# game.play