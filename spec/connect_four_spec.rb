require_relative "../lib/main_game"

describe Game do
  subject(:game) { described_class.new }
  context '#draw' do
    it 'prints a seven-column six-row grid' do
      allow(game).to receive :puts
      expect(game).to receive(:print).with(EMPTY, ' ').exactly(42).times
      game.draw
    end
  end

  context '#place_color' do
    let(:column) { 2 }
    subject(:game_place_valid) { described_class.new }
    before do
      allow(game_place_valid).to receive(:valid_play?).and_return(true)
    end
    it 'when placing a valid white piece, returns white and the top piece is white' do
      expect(game_place_valid.place_color(column, WHITE)).to eq(WHITE)
      columns = game_place_valid.get_column(column)
      top = EMPTY
      (columns.size - 1).downto(0) { |row| top = columns[row] if columns[row] != EMPTY}
      expect(top).to eq(WHITE)
    end
    let(:invalid_column) { 15 }
    it 'returns false when trying an invalid play' do
      expect(game.place_color(invalid_column, WHITE)).to be false
    end
  end
  
  context '#valid_play?' do
    let(:column) { 0 }
    it 'returns true when there are free spaces in the column' do
      expect(game).to be_valid_play column
    end 

    it 'returns false when there is no free spaces' do
      game.place_color(column, BLACK)
      game.place_color(column, WHITE)
      game.place_color(column, BLACK)
      game.place_color(column, WHITE)
      game.place_color(column, BLACK)
      game.place_color(column, WHITE)
      expect(game).not_to be_valid_play(column)
    end
  end

  context '#empty_cell?' do
    subject(:game_empty) { described_class.new }
    let(:row) { 5}
    let(:column) { 1 }
    it 'returns true when the cell [5][1] is empty' do
      expect(game_empty).to be_empty_cell(row, column)
    end
    
    subject(:game_not_empty) { described_class.new }
    before do
      game_not_empty.place_color(column, BLACK)
    end
    it 'returns false when the cell [5][1] is not empty' do
      expect(game_not_empty).not_to be_empty_cell(row, column)
    end
  end

  context '#game_over?' do
    subject(:game_over) { described_class.new }
    it 'returns false when not connecting 4 of the same color' do
      expect(game_over).not_to be_game_over
    end
    
    it 'returns true when a connecting 4 pieces of the same color in horizontal' do
      game_over.place_color(1, BLACK)
      game_over.place_color(2, BLACK)
      game_over.place_color(3, BLACK)
      game_over.place_color(4, BLACK)
      expect(game_over).to be_game_over
    end

    it 'returns true when connecting 4 pieces of the same color in vertical' do
      game_over.place_color(1, BLACK)
      game_over.place_color(1, WHITE)
      game_over.place_color(1, WHITE)
      game_over.place_color(1, WHITE)
      game_over.place_color(1, WHITE)
      expect(game_over).to be_game_over
    end

    it 'returns true when connecting 4 pieces of the same color in diagonal' do
      game_over.place_color(1, BLACK)
    
      game_over.place_color(2, WHITE)
      game_over.place_color(2, BLACK)
    
      game_over.place_color(3, BLACK)
      game_over.place_color(3, WHITE)
      game_over.place_color(3, BLACK)
    
      game_over.place_color(4, WHITE)
      game_over.place_color(4, BLACK)
      game_over.place_color(4, WHITE)
      game_over.place_color(4, BLACK)
    
      expect(game_over).to be_game_over
    end
  end
  
  context '#next_turn' do
    subject(:game_next_turn) { described_class.new }
    it 'It changes between black and white' do
      allow(game_next_turn).to receive(:valid_input).and_return(1)
      allow(game_next_turn).to receive(:puts)
      initial_turn = game_next_turn.instance_variable_get(:@current_turn)
      game_next_turn.next_turn
      current_turn = game_next_turn.instance_variable_get(:@current_turn)
      expect(current_turn).to eq(BLACK) || eq(WHITE)
      expect(current_turn).not_to eq(initial_turn)
    end
  end
  
  context '#player_turn' do
    subject(:game_player_turn) { described_class.new }

    it 'asks the current color for a position to place their piece' do
      allow(game_player_turn).to receive(:valid_input).and_return(1)
      current = game_player_turn.instance_variable_get(:@current_turn)
      message = "Select a position to play (1-7) #{current}"
      expect(game_player_turn).to receive(:puts).with(message)
      game_player_turn.player_turn
    end
    
    it 'keeps asking until input is in range 1..7' do
      expect(game_player_turn).to receive(:puts)
      message = 'invalid play, select a number between 1 and 7'
      invalid_one = '0'
      invalid_two = '8'
      valid = '5'
      allow(game_player_turn).to receive(:gets).and_return(invalid_one, invalid_two, valid)
      expect(game_player_turn).to receive(:puts).with(message).at_least(2).times
      game_player_turn.player_turn
    end
    
    it 'places the piece of the current player in the position choosed' do
      allow(game_player_turn).to receive(:puts)
      allow(game_player_turn).to receive(:gets).and_return("1")
      current_player = game_player_turn.instance_variable_get(:@current_turn)
      expect(game_player_turn).to receive(:place_color).and_return(current_player)
      game_player_turn.player_turn
    end

    it 'keeps asking for an input if it is not a valid play' do
      allow(game_player_turn).to receive(:valid_input).and_return(1, 1, 4)
      allow(game_player_turn).to receive(:puts)
      game_player_turn.place_color(1, BLACK)
      game_player_turn.place_color(1, BLACK)
      game_player_turn.place_color(1, WHITE)
      game_player_turn.place_color(1, BLACK)
      game_player_turn.place_color(1, BLACK)
      game_player_turn.place_color(1, BLACK)
      message = "Select another position to play (1-7)"
      game_player_turn.player_turn
      expect(game_player_turn).to have_received(:puts).with(message).twice
    end
  end
  
  context '#play' do
    subject(:game_play) { described_class.new }
    it 'asks for first player color' do
      allow(game_play).to receive(:gameplay_loop)
      allow(game_play).to receive(:gets).and_return("w")
      message = "Select player 1 color (white or black)"
      expect(game_play).to receive(:puts).with(message)
      game_play.play
    end

    it 'asks for valid input twice until it is valid' do
      allow(game_play).to receive(:gameplay_loop)
      invalid_one = '12'
      invalid_two = 'o'
      message = "Insert a valid input"
      allow(game_play).to receive(:gets).and_return(invalid_one, invalid_two, "w")
      expect(game_play).to receive(:puts)
      expect(game_play).to receive(:puts).with(message).at_least(2).times
      game_play.play
    end

    it "set black as current player when user is prompted to select first player's color" do
      allow(game_play).to receive(:gameplay_loop)
      allow(game_play).to receive(:puts)
      allow(game_play).to receive(:gets).and_return("black")
      game_play.play
      current = game_play.instance_variable_get(:@current_turn)
      expect(current).to eq BLACK
    end

    it 'loops between players until game_over? triggers' do
      allow(game_play).to receive(:puts)
      allow(game_play).to receive(:print)
      first_color = 'w'
      allow(game_play).to receive(:gets).and_return(first_color,'1','2','1','2','1','2','1')
      game_play.play
      expect(game_play.game_over?).to be true
    end
  end
end