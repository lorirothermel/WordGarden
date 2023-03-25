//
//  ContentView.swift
//  WordGarden
//
//  Created by Lori Rothermel on 3/24/23.
//

import SwiftUI
import AVFAudio


struct ContentView: View {
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var currentWordIndex = 0
    @State private var guessedLetter = ""
    @State private var guessesRemaining = 8
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer!
        
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var imageName = "flower8"
    
    @FocusState private var textFieldIsFocused: Bool
    
    private let wordsToGuess = [ "GREENE",
                                 "ROETHLISBERGER",
                                 "HAM",
                                 "WOODSON",
                                 "LAMBERT",
                                 "BLOUNT",
                                 "POLAMALU",
                                 "BRADSHAW",
                                 "HARRIS",
                                 "WARD",
                                 "BETTIS",
                                 "STALLWORTH",
                                 "SWANN",
                                 "WEBSTER",
                                 "HARRISON",
                                 "MILLER",
                                 "DAWSON",
                                 "BLEIER",
                                 "SHELL",
                                 "GREENWOOD",
                                 "FANECA",
                                 "LLOYD",
                                 "HAMPTON"  ]
    
    private let maximumGuesses = 8
    
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Words Guessed: \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }  // VStack
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text("Words in Game: \(wordsToGuess.count)")
                }  // VStack
            }  // HStack
            .padding(.horizontal)
            
            Spacer()
            
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            
            Spacer()
                       
            Text(revealedWord)
                .font(.title)
            
            if playAgainHidden {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)   // Change keyboard having "return" to "done"
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) { _ in
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else { return }
                            guessedLetter = String(lastChar).uppercased()
                        }  // onChange
                        .onSubmit {
                            guard guessedLetter != "" else {
                                return
                            }
                            guessALetter()
                            updateGamePlay()
                        }
                        .focused($textFieldIsFocused)
                    
                    Button("Guess a Letter") {
                        guessALetter()
                        updateGamePlay()
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }  // HStack
            } else {
                Button(playAgainButtonLabel) {
                    // If all words have been guessed
                    if currentWordIndex == wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }
                    // Reset after a word was guessed or missed.
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count - 1)
                    lettersGuessed = ""
                    guessesRemaining = maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                    playAgainHidden = true
                }  // Button Another Word? End
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            } // if playAgainHidden End
            
           Spacer()
           
           Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.7), value: imageName)
            
//            Text("Pittsburgh Steeler Greats")
//                .font(.title)
//                .foregroundColor(.red)
//                .padding(.vertical, 25)
        }  // VStack
        .ignoresSafeArea(edges: .bottom)
        .onAppear() {
            wordToGuess = wordsToGuess[currentWordIndex]
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count - 1)
            guessesRemaining = maximumGuesses
        }
    }  // some View
    
    func guessALetter() {
        
        textFieldIsFocused = false
        lettersGuessed = lettersGuessed + guessedLetter
        
        revealedWord = ""
        
        // Loop through all the letters in wordToGuess
        for letter in wordToGuess {
            // Check if letter in wordToGuess is in lettersGuessed ie Did you guess this letter already?
            if lettersGuessed.contains(letter) {
                revealedWord = revealedWord + "\(letter) "
            } else {
                // if not add an underscore + a blank space, to revealedWord
                revealedWord = revealedWord + "_ "
            }
        }

        revealedWord.removeLast()
                  
    }
    
    
    func updateGamePlay() {
                
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            // Animate crumbling leaf and play "incorrect sound
            imageName = "wilt\(guessesRemaining)"
            playSound(soundName: "incorrect")
            
            // Delay change to flower image until after wilt animation is done.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageName = "flower\(guessesRemaining)"
            }  // DispathQueue
        } else {
            playSound(soundName: "correct")
        }
        
        // When do we play another word?
        if !revealedWord.contains("_") {    // Guessed when no underscores in revealedWord
            gameStatusMessage = "You've Guessed It! It Took You \(lettersGuessed.count) Guesses to Guess the Word!"
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-guessed")
        } else if guessesRemaining == 0 {   // Word missed
            gameStatusMessage = "Sooo Sorry! You are All Out of Guesses."
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-not-guessed")
        } else {   // Keep guessing
            gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es")."
        }
        
        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\nYou've Tried All of the Words. Restart from the Beginning?"
        }
        
        guessedLetter = ""
    }
    
    
    func playSound(soundName: String) {
        
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("🤬 Could not read file name \(soundName))")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("🤬 ERROR: \(error.localizedDescription) creating audioPlayer")
        }
    }  // End of playSound func
    
    
    
    
}  // ContentView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
