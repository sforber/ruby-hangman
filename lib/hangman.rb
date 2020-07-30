STDOUT.sync = true

class Hangman
    def initialize
        @guess_remaining = 10
        dictionary = File.readlines "dictionary.txt"
        @wrong_letters = []
        @used_letters = []
        @win_check = false
        @game_end = false
        @save_end = false
        @secret_word = dictionary[rand(dictionary.length)].downcase.chop
        while @secret_word.length > 12 || @secret_word.length < 5
            @secret_word = dictionary[rand(dictionary.length)].downcase.chop
        end
        @dashed_word = []
        for i in (1..@secret_word.length)
            @dashed_word.append("_")
        end
        newGame()
    end

    def newGame
        puts "Welcome to Hangman. Please enter, P to play or L to load a saved game: "
        menu_input = gets.downcase.chomp
        while menu_input != "p" && menu_input != "l"
            puts "Plese enter, P to play or L to load a saved game: "
            menu_input = gets.downcase.chomp
        end
        if menu_input == "p"
            playRound()
        else
            loadGame()
        end
    end

    def playRound
        until @guess_remaining == 0 || @game_end == true
            puts "\nGuess a letter or type \'save\' to save your current game: "
            user_guess = gets.downcase.chomp
            while validInput(user_guess) != true || @used_letters.include?(user_guess)
                puts "\nGuess a letter or type \'save\' to save your current game: "
                user_guess = gets.downcase.chomp
            end
            if user_guess == "save"
                saveGame()
            else
                checkResult(user_guess)
                displayResults()
                checkWin()
            end
        end
        endResult()
    end

    def loadGame
        if File.exist? "saved_game.txt"
            saved_game = File.readlines("saved_game.txt")
            i = 1
            saved_game.map do |row|
                if i == 1
                    @secret_word = row.chop
                elsif i == 2
                    @dashed_word = (((row.delete "\"").delete "]").delete"[").chop.split(", ") 
                elsif i == 3
                    @guess_remaining = row.chop.to_i
                elsif i == 4
                    @used_letters = (((row.delete "\"").delete "]").delete"[").chop.split(", ") 
                else
                    @wrong_letters = (((row.delete "\"").delete "]").delete"[").chop.split(", ") 
                end
                i += 1
            end
            displayResults()
            playRound()
        else
            puts "No saved game"
            playRound()
        end
    end 

    def saveGame
        @save_end = true
        save_data = [@secret_word, @dashed_word, @guess_remaining, @used_letters, @wrong_letters]
        filename = "saved_game.txt"
        saved_game = File.open(filename, "w")
        save_data.each do |item|
            saved_game.puts "#{item}"
        end
        saved_game.close
        puts "\n Game Saved"
        @game_end = true
    end

    def displayResults
        system 'clear'
        puts "Hidden Word: #{@dashed_word.join(',')}"
        puts "Incorrect letters: #{@wrong_letters.join(',')}"
        puts "Guesses remaining: #{@guess_remaining}"
    end

    def checkWin
        letters_matched = 0
        secret_split = @secret_word.split("")
        secret_split.each_with_index do |letter, index|
            if letter == @dashed_word[index]
                letters_matched += 1
                if letters_matched == secret_split.length
                    @win_check = true
                    @game_end = true
                end
            end
        end
    end

    def checkResult(guess)
        if @secret_word.include?(guess)
            secret_split = @secret_word.split("")
            secret_split.each_with_index do |letter, index|
                if guess == letter
                    @dashed_word[index] = guess
                    @used_letters.append(guess)    
                end
            end
        else
            @guess_remaining -= 1
            @wrong_letters.append(guess)
            @used_letters.append(guess)
        end
    end

    def validInput(input)
        if input.length == 1 && input.match?(/\A[a-z]*\z/)
            return true
        elsif input == "save"
            return true
        else 
            return false
        end
    end

    def endResult
        if @win_check == true
            puts "Congratulations! You guessed the secret word: #{@secret_word}"
        elsif @win_check == false && @save_end == false
            puts "Game Over! The secret word was: #{@secret_word}"
        end
    end
end

game = Hangman.new

#save_game - Saves variables to file and ends game
#load_game - Loads game from file displays board and plays round
#display_results - Displays the board, guesses remaining and letters used
#play_round - Asks for user input and then checks this is valid (can be letter or save)
#valid_input - Checks the input is valid, either check_results or savegame
#check_results - check letter is in secret and if is, add letter to letters used and to dashed word. If not add to letters guessed and -= guesses left
#check_win - Check dashed word and secret are equal, game end = true.