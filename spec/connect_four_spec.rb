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
end