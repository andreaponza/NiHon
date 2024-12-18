import SwiftUI
import AVFoundation

func readText(_ testo: String) {
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: testo)
    
    // Imposta la lingua giapponese
    utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
    
    // Configura la velocità e il tono della voce
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
    utterance.pitchMultiplier = 1.0
    
    // Avvia la sintesi vocale
    synthesizer.speak(utterance)
}


struct Word {
    var kanji: String // Word in kanji
    var hiraKata: String // Word in hiragana o katakana
    var romaji: String // Word in romaji
    var mean: String // Mean
}

class CSVParser {
    // Load CSV from URL
    static func loadCSV(from urlString: String, completion: @escaping ([Word]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching CSV: \(error)")
                completion([])
                return
            }
            
            guard let data = data, let csvData = String(data: data, encoding: .utf8) else {
                print("Invalid CSV data")
                completion([])
                return
            }
            
            var words: [Word] = []
            let rows = csvData.components(separatedBy: "\n")
            
            for row in rows.dropFirst() {
                let columns = row.components(separatedBy: ";")
                if columns.count == 4 {
                    let word = Word(kanji: columns[0], hiraKata: columns[1], romaji: columns[2], mean: columns[3])
                    words.append(word)
                }
            }
            
            completion(words)
        }.resume()
    }

    // Load CSV from local file
    static func loadCSV(from filename: String) -> [Word] {
        var words: [Word] = []
        
        guard let filePath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            print("File CSV not found")
            return []
        }
        
        do {
            let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
            let rows = csvData.components(separatedBy: "\n")
            
            for row in rows.dropFirst() {
                let columns = row.components(separatedBy: ";")
                if columns.count == 4 {
                    let word = Word(kanji: columns[0], hiraKata: columns[1], romaji: columns[2], mean: columns[3])
                    words.append(word)
                }
            }
        } catch {
            print("Error reading local CSV: \(error)")
        }
        
        return words
    }
    
}

struct ContentView: View {
    @FocusState private var isButtonFocused: Bool
    @State private var words: [Word] = []
    @State private var randomWord: Word? = nil
    @State private var userInput: String = ""
    @State private var comparisonResult: String = ""
    @State private var mean: String = ""
    @State private var romaji: String = ""
    @State private var exercise = ["Hiragana", "Katakana", "Words"]
    @State private var file: String = ""
    
    func oneTimeRandomWord() -> Word? {
        guard !words.isEmpty else { return nil }
        let randomIndex = Int.random(in: 0..<words.count)
        return words.remove(at: randomIndex)
    }
    
    let remoteCSVURL = "https://raw.githubusercontent.com/andreaponza/NiHon/refs/heads/main/NiHon/Words.csv"
    
    var body: some View {
        VStack {
            // Menu for choosing between local and remote files
            Menu("Choose Source") {
                Button("Load Hiragana", action: {
                    words = CSVParser.loadCSV(from: "Hiragana")
                    randomWord = oneTimeRandomWord()
                    file = "Hiragana"
                    userInput = ""
                    comparisonResult = ""
                    mean = ""
                    romaji = ""
                })
                Button("Load Katakana", action: {
                    words = CSVParser.loadCSV(from: "Katakana")
                    randomWord = oneTimeRandomWord()
                    file = "Katakana"
                    userInput = ""
                    comparisonResult = ""
                    mean = ""
                    romaji = ""
                })
                Button("Load Remote Words", action: {
                    CSVParser.loadCSV(from: remoteCSVURL) { fetchedWords in
                        DispatchQueue.main.async {
                            words = fetchedWords
                            randomWord = oneTimeRandomWord()
                            file = "Remote Words"
                            userInput = ""
                            comparisonResult = ""
                            mean = ""
                            romaji = ""
                        }
                    }
                })
                Button("Load Words", action: {
                    words = CSVParser.loadCSV(from: "Words")
                    randomWord = oneTimeRandomWord()
                    file = "Words"
                    userInput = ""
                    comparisonResult = ""
                    mean = ""
                    romaji = ""
                })
            }
            .padding()
            
            if let randomWord = randomWord {
                Text(file)
                    .font(.headline)
                    .padding()
                
                Text("\(randomWord.kanji)\n\(randomWord.hiraKata)")
                    .font(.system(size: 50))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text(comparisonResult)
                    .foregroundColor(comparisonResult == "Correct!" ? .green : .red)
                    .padding()
                
                Text("Romaji: \(romaji)")
                Text("Mean: \(mean)")
                
                TextField("Insert romaji", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: userInput) {
                        if userInput.uppercased() == randomWord.romaji.uppercased() {
                            comparisonResult = "Correct!"
                            romaji = randomWord.romaji.uppercased()
                            mean = randomWord.mean.uppercased()
                        } else {
                            comparisonResult = ""
                        }
                    }
                HStack{
                    Button("🔊"){
                        readText(randomWord.hiraKata)
                    }
                    
                    
                    Button("Show solution!") {
                        romaji = randomWord.romaji.uppercased()
                        mean = randomWord.mean.uppercased()
                    }
                    .padding()
                }
                
            } else {
                Text("Select exercise ...")
            }
            
            Button("Next word \(words.count)") {
                randomWord = oneTimeRandomWord()
                userInput = ""
                comparisonResult = ""
                romaji = ""
                mean = ""
            }
            .padding()
            .focused($isButtonFocused)
            .keyboardShortcut(.defaultAction)
            
        }
        .onAppear {
            // Load a random local file initially
            file = exercise.randomElement()!
            words = CSVParser.loadCSV(from: file)
            randomWord = oneTimeRandomWord()
            isButtonFocused = true
        }
        .containerBackground(.brown.gradient, for: .window)
        .textSelection(.enabled)
    }
}
