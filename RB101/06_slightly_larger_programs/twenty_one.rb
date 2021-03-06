=begin rdoc

= PEDAC Template

== (Understand the) Problem

First, identify the inputs and the outputs of the problem

* Inputs:
  1. User ("player") input: "hit" or "stay" strings to determine the next
  action to do
* Output:
  1. The winner ("dealer" or "player") and the score

---

*Problem Domain:*
Trump cards, logic

---

*Implicit Requirements:*
* Knowing the rules
* There can be a tie if both player and dealer have the same score
* Must know what a 52-card deck consists of

---

*Clarifying Questions:*

1. N/A

---

*Mental Model:*
Create a game of Twenty-One that asks the player for his/her next move and
compute the result, as well as the dealer result. Find a winner.

---

== Examples / Test Cases / Edge Cases

*Examples:*

N/A

---

== Data Structure

*Your Data Structure:*
A hash per suits for the deck of cards and their respective value.
Another hash for the player and another one for the dealer.

---

== Algorithm

*Your Algorith:*
$MAIN
1. Initialize the 4 suits of cards
2. Draw 2 cards for the dealer
3. Draw 2 cards for the player
4. $PLAYER_TURN

$PLAYER_TURN
1. $DISPLAY_HAND
2. Ask for "hit" or "stay"
  1. "hit": loop and ask for another card
    1. Total exceed 21: break the loop and go to $DISPLAY_RESULT (dealer wins)
  3. "stay": break the loop and go to $DEALER_TURN

$DEALER_TURN
1. Check if current result is equal or superior to 17
  1. YES: dealer stays (go to $DISPLAY_RESULT)
  2. NO: dealer hits
    1. If dealer busts, break the loop and go to $DISPLAY_RESULT (player wins)

$DISPLAY_HAND
1. Show dealer's hand first card
2. Show players's hand, if any

$DISPLAY_RESULT
1. Calculate the total value of the cards of both player and dealer
2. Check who has the highest value
3. Display the winner

== Code

=end
SUIT = { 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8,
         9 => 9, 10 => 10, :jack => 10, :queen => 10, :ace => nil }
CARDS = SUIT.keys
# Constants below can be changed to update game experience
BUST = 21
DEALER_LIMIT = 17
GOAL = 5

def greeting
  system 'clear'
  puts "Howdy! Welcome to Twenty One!\n\n"

  puts "Your goal is to try to get as close to #{BUST} as possible,\n" \
       "without going over. If you go over #{BUST}, you lose. :-(\n\n"

  puts "Just remember this easy rules:\n" \
       "- Cards 2 to 10 are worth their face value.\n" \
       "- Jack, Queen and King are worth 10.\n" \
       "- Ace is worth 11 or 1 if your total score exceed #{BUST}.\n\n"

  puts "You will play against the Dealer. In order to be the Grand\n" \
       "Winner, you shall beat the game #{GOAL} times before the Dealer!\n" \
       "Good luck!\n\n"

  puts "-------------"
  puts "\n"
end

def initialize_deck
  hearts = SUIT.dup
  # A hacky hack to deep copy hashes
  diamonds = Marshal.load(Marshal.dump(hearts))
  clubs = Marshal.load(Marshal.dump(hearts))
  spades = Marshal.load(Marshal.dump(hearts))

  [hearts, diamonds, clubs, spades]
end

def display_dealer_first_card(dealer_hand)
  puts "Dealer has: #{dealer_hand[0]} and unknown card."
end

def build_display_hand(hand)
  hand_size = hand.size
  hand_string = ''
  i = 0

  while i <= hand_size - 1
    hand_string << if i == hand_size - 1
                     hand[i].to_s
                   elsif i == hand_size - 2
                     hand[i].to_s + ' and '
                   else
                     hand[i].to_s + ', '
                   end

    i += 1
  end

  hand_string
end

def display_hand(hand, subject)
  puts "#{subject} have: #{build_display_hand(hand)}."
end

def player_answer
  answer = ''
  puts '(h)it or (s)tay?'

  loop do
    answer = gets.chomp
    break if answer.downcase.start_with?('h', 's')
    puts "Sorry, I didn't understand that. Please input (h)it or (s)tay."
  end

  answer
end

def player_hand_refinement(dealer_hand, player_hand, deck)
  loop do
    system 'clear'
    display_dealer_first_card(dealer_hand)
    display_hand(player_hand, 'You')
    answer = player_answer

    player_hand += draw_cards(deck, 1) if answer.downcase.start_with?('h')
    break if answer.downcase.start_with?('s') || busted?(player_hand)
  end

  player_hand
end

def dealer_hand_refinement(hand, deck)
  while calculate_score(hand) < DEALER_LIMIT
    hand += draw_cards(deck, 1)
  end

  hand
end

def draw_cards(deck, num)
  hand = []

  while hand.size < num
    random_num = (0..deck.size - 1).to_a.sample
    random_card = CARDS.sample

    if deck[random_num].key?(random_card)
      hand << random_card
      deck[random_num].delete(random_card)
    end
  end

  hand
end

def calculate_aces(hand)
  aces = hand.count(nil)
  # Add zero to array to prevent exception
  # NoMethodError: undefined method `+' for nil:NilClass
  # when hand = [nil, nil] at hand.compact.reduce(:+) + 11
  hand.unshift(0)

  aces.times do
    hand << (hand.compact.reduce(:+) + 11 <= BUST ? 11 : 1)
  end

  # Remove added zero to prevent exception
  # TypeError: nil can't be coerced into Integer
  # down the road at SUIT[card]
  hand.shift

  hand.compact
end

def convert_hand_to_numeric(hand)
  hand.map do |card|
    SUIT[card]
  end
end

def calculate_score(hand)
  numeric_hand = convert_hand_to_numeric(hand)
  reduced_hand = calculate_aces(numeric_hand)
  score = 0

  reduced_hand.each do |card|
    score += if card == 11 || card == 1
               card
             else
               SUIT[card]
             end
  end

  score
end

def busted?(hand)
  score = calculate_score(hand)

  score > BUST
end

def display_busted(hand, busted_player)
  puts "#{busted_player} busted hard! #{busted_player} hand's score is " \
       "#{calculate_score(hand)}!"
end

def display_winner(dealer_score, player_score, winner)
  case winner
  when :dealer
    puts "Dealer wins with #{dealer_score}!"
    puts "Your score is #{player_score}."
  when :player
    puts "You win with #{player_score}!\n"
    puts "Dealer's score is #{dealer_score}."
  else
    puts "It's a tie!"
    puts "Dealer: #{dealer_score}"
    puts "Player: #{player_score}"
  end
end

def compare_cards(dealer_score, player_score)
  winner = nil

  if dealer_score > player_score
    winner = :dealer
  elsif dealer_score < player_score
    winner = :player
  end

  winner
end

def find_winner(dealer_hand, player_hand)
  winner = nil

  if busted?(player_hand)
    display_busted(player_hand, "You")
    winner = :dealer
  elsif busted?(dealer_hand)
    display_busted(dealer_hand, "Dealer")
    winner = :player
  else
    dealer_score = calculate_score(dealer_hand)
    player_score = calculate_score(player_hand)
    winner = compare_cards(dealer_score, player_score)
    display_winner(dealer_score, player_score, winner)
  end

  winner
end

def play_again?
  answer = ''

  puts "\n"
  puts "-------------"
  puts "Do you want to play again? ('y' or 'n')"
  loop do
    answer = gets.chomp
    break if answer.downcase.start_with?('y', 'n')
    puts "Sorry, I didn't understand that. Please input 'y' or 'n'"
  end
  answer.downcase.start_with?('y')
end

def keep_score(winner, score_board)
  score_board[winner].nil? ? score_board : score_board[winner] += 1

  score_board
end

def grand_winner?(score_board)
  puts "\n"
  puts "-------------"

  if score_board[:dealer] == GOAL
    puts "Dealer is the grand winner and the first to reach #{GOAL}!"
    puts "Player's final score is #{score_board[:player]}."
    true
  elsif score_board[:player] == GOAL
    puts "Player is the grand winner and the first to reach #{GOAL}!"
    puts "Dealer's final score is #{score_board[:dealer]}."
    true
  else
    false
  end
end

score_board = { dealer: 0,
                player: 0 }

greeting

loop do
  deck = initialize_deck
  dealer_hand = draw_cards(deck, 2)
  player_hand = draw_cards(deck, 2)
  final_player_hand = player_hand_refinement(dealer_hand, player_hand, deck)
  final_dealer_hand = dealer_hand_refinement(dealer_hand, deck)

  system 'clear'
  winner = find_winner(final_dealer_hand, final_player_hand)

  puts "\n"
  final_dealer_hand = dealer_hand if busted?(final_player_hand)
  display_hand(final_dealer_hand, 'Dealer')
  display_hand(final_player_hand, 'You')

  score_board = keep_score(winner, score_board)

  break if grand_winner?(score_board)

  puts "\n"
  puts "Dealer current score is #{score_board[:dealer]}."
  puts "Player current score is #{score_board[:player]}."

  break unless play_again?
  system 'clear'
end

puts "Thank you for playing Twenty-One! Good bye!"
