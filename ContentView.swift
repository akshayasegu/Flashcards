import SwiftUI

import SwiftUI

struct Flashcard: Identifiable {
    var id = UUID()
    var term: String
    var def: String
    var isShowingTerm = true
}

class FlashcardViewModel: ObservableObject {
    @Published var flashcards = [Flashcard]()
    @Published var isShowingFlashcardView = false
    @Published var isShowingGradeView = false
    
    func addFlashcard(term: String, definition: String) {
        let flashcard = Flashcard(term: term, def: definition)
        flashcards.append(flashcard)
    }
    
    func startOver() {
        flashcards.removeAll()
    }
    
    func setupFieldsNotEmpty() -> Bool {
        return flashcards.count > 0
    }
}
struct correctincorrect: View{
    var systemimage: String
    var body: some View {
        ZStack {
            Image(systemName: systemimage)
                .resizable()
                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
                .scaledToFit()
                .frame(width: 30,height: 30)
                .zIndex(1.0)
            
            Circle()
                .stroke(lineWidth: 10)
                .frame(width: 70, height: 70)
                .foregroundColor(Color(red: 0.32, green: 0.42, blue: 0.71))
        }
    }
}
struct DonutCircleChart: View {
    var correctCount: Int
    var totalCount: Int
    var colors: Color
    private var correctPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(correctCount) / Double(totalCount)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(Color.gray)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(correctPercentage, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(colors)
                .rotationEffect(Angle(degrees: 270))
            
            Text("\(correctCount)/\(totalCount)")
                .font(.title)
        }
    }
}
struct ContentView: View {
    @StateObject var viewModel = FlashcardViewModel()
    @State private var term = ""
    @State private var definition = ""
    public struct PlaceholderStyle: ViewModifier {
        var showPlaceHolder: Bool
        var placeholder: String

        public func body(content: Content) -> some View {
            ZStack(alignment: .leading) {
                if showPlaceHolder {
                    Text(placeholder)
                    .padding(.horizontal, 15)
                }
                content
                .foregroundColor(Color.white)
                .padding(5.0)
            }
        }
    }
    var body: some View {
        Color(red: 0.80, green: 0.80, blue: 0.80)
            .ignoresSafeArea()
            .overlay {
            VStack {
                Text("Create Flashcards")
                    .foregroundColor(Color(red: 0.32, green: 0.42, blue: 0.71))
                    .bold()
                    .font(.largeTitle)
                HStack {
                    Spacer()
                    TextField("Term", text: $term)
                        .padding()
                        .foregroundColor(Color(red: 0.80, green: 0.80, blue: 0.80))
                        .background(Color(red: 0.55, green: 0.55, blue: 0.55))
                        .cornerRadius(5)
                        .accentColor(Color(red: 0.32, green: 0.42, blue: 0.71))
                    Spacer()
                    TextField("Definition", text: $definition)
                        
                        .foregroundColor(Color(red: 0.80, green: 0.80, blue: 0.80))
                        .padding()
                        .background(Color(red: 0.55, green: 0.55, blue: 0.55))
                        //.background(Color.black)
                        .cornerRadius(5)
                        .accentColor(Color(red: 0.32, green: 0.42, blue: 0.71))
                    Spacer()
                }
                
                Button {
                    viewModel.addFlashcard(term: term, definition: definition)
                    term = ""
                    definition = ""
                } label: {
                    Text("Add Flashcard")
                        .bold()
                        .font(.title2)
                        .foregroundColor(Color(red: 0.32, green: 0.42, blue: 0.71))
                        .frame(width: 250, height: 50)
                }
                if viewModel.flashcards.count >= 1 {
                    Text("Flashcards:")
                        .bold()
                        .font(.title2)
                        //.foregroundColor(Color(red: 0.40, green: 0.40, blue: 0.40))
                        .frame(width: 250, height: 15)
                    ForEach(viewModel.flashcards) { flashcard in
                        Text("\(flashcard.term) - \(flashcard.def)")
                            .font(.title2)
                            //.foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
                    }
                }
                Button(action: {
                    viewModel.startOver()
                }, label: {
                    Text("Start Over")
                        .bold()
                        .font(.title3)
                        .foregroundColor(Color(red: 0.32, green: 0.42, blue: 0.71))
                        .frame(width: 200, height: 5)
                })
                Button {
                    viewModel.isShowingFlashcardView = true
                } label: {
                    Text("Begin Test")
                        .bold()
                        .font(.title3)
                        .foregroundColor(Color(red: 0.32, green: 0.42, blue: 0.71))
                        .frame(width: 200, height: 5)
                }
                .disabled(!viewModel.setupFieldsNotEmpty())
                .padding()
            }
            .sheet(isPresented: $viewModel.isShowingFlashcardView) {
                FlashcardView(viewModel : viewModel)
            }
            .padding()
        }
    }
}

struct FlashcardView: View {
    @ObservedObject var viewModel: FlashcardViewModel
    @State private var currentCardIndex = 0
    @State var correct = 0
    @State var incorrect = 0
    @State var incorrectflashcards: [Flashcard] = []
    private func moveToNextCard() {
        if currentCardIndex < viewModel.flashcards.count - 1 {
            currentCardIndex += 1
        } else {
            viewModel.isShowingGradeView = true
        }
    }
    var body: some View {
        @State var termdef = viewModel.flashcards[currentCardIndex].term
        Color(red: 0.80, green: 0.80, blue: 0.80)
            .ignoresSafeArea()
            .overlay {
                VStack {
                    Text("Flashcards")
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(Color(red: 0.32, green: 0.42, blue: 0.71))
                    ZStack {
                        Button {
                            viewModel.flashcards[currentCardIndex].isShowingTerm.toggle()
                        } label: {
                            Text(viewModel.flashcards[currentCardIndex].isShowingTerm ? viewModel.flashcards[currentCardIndex].term : viewModel.flashcards[currentCardIndex].def)
                                .font(.largeTitle)
                                .padding()
                                .foregroundColor(Color(red: 0.80, green: 0.80, blue: 0.80))
                        }
                        .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                        Rectangle()
                            .frame(width: 325, height: 200)
                            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
                            .cornerRadius(20)
                    }
                    HStack{
                        Spacer()
                        ZStack{
                            Button {
                                correct += 1
                                moveToNextCard()
                            } label: {
                                correctincorrect(systemimage: "checkmark")
                            }
                        }
                        Spacer()
                        ZStack {
                            Button {
                                incorrect += 1
                                incorrectflashcards.append(viewModel.flashcards[currentCardIndex])
                                moveToNextCard()
                            } label: {
                                correctincorrect(systemimage: "multiply")
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .padding()
                    .sheet(isPresented: $viewModel.isShowingGradeView) {
                        GradeView(viewModel:viewModel, correct:correct, incorrect:incorrect, incorrectflashcards:incorrectflashcards)
                    }
                }
            }
    }
}
struct GradeView: View {
    @ObservedObject var viewModel: FlashcardViewModel
    @State var correct:Int
    @State var incorrect:Int
    @State var incorrectflashcards: [Flashcard]
    var body: some View {
        Color(red: 0.80, green: 0.80, blue: 0.80)
            .ignoresSafeArea()
            .overlay {
                VStack {
                    Text("Results")
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(Color(red: 0.32, green: 0.42, blue: 0.71))
                    HStack{
                        Spacer()
                        DonutCircleChart(correctCount: correct, totalCount: correct + incorrect, colors: Color.green)
                            .frame(width: 100, height: 100)
                        Spacer()
                        DonutCircleChart(correctCount: incorrect, totalCount: correct + incorrect, colors: Color.red)
                            .frame(width: 100, height: 100)
                        Spacer()
                    }
                    Text("Well Done!")
                        .padding()
                        .font(.title)
                        .bold()
                        .frame(height: 50)
                    if incorrect != 0 {
                        Text("Incorrect Answers")
                            .font(.title)
                            .bold()
                    }
                    
                    ForEach(incorrectflashcards) { flashcard in
                        Text("\(flashcard.term) - \(flashcard.def)")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
                    }
                }
        }
    }
}
