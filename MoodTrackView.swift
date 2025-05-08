//
//  MoodTrackView.swift
//  Chiron
//
//  Created by ak on 2/11/25.
//

import SwiftUI

struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var mood: Int
    var notes: String
    var symptoms: [String]
}

class MoodStorage: ObservableObject {
    @Published var moodEntries: [MoodEntry] {
        didSet {
            saveMoodEntries()
        }
    }
    
    init() {
        self.moodEntries = UserDefaults.standard.loadMoodEntries()
    }
    
    func saveMoodEntries() {
        UserDefaults.standard.saveMoodEntries(moodEntries)
    }
}

extension UserDefaults {
    private static let moodKey = "moodEntries"
    
    func saveMoodEntries(_ moodEntries: [MoodEntry]) {
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            set(encoded, forKey: UserDefaults.moodKey)
        }
    }
    
    func loadMoodEntries() -> [MoodEntry] {
        if let savedData = data(forKey: UserDefaults.moodKey),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: savedData) {
            return decoded
        }
        return []
    }
}

struct MoodTrackView: View {
    @State private var mood: Int = 2 // Default to neutral
    @State private var notes: String = ""
    @State private var symptoms: [String] = []
    @ObservedObject var moodStorage: MoodStorage
    @Environment(\.presentationMode) var presentationMode  // To navigate back
    
    let moodImages = ["very_sad", "sad", "neutral", "happy", "very_happy"]
    let moodDescriptions = ["Very Sad", "Sad", "Neutral", "Happy", "Very Happy"]
    let symptomOptions = ["Tremors", "Stiffness", "Fatigue", "Headache", "Dizziness", "Nausea", "Anxiety", "Brain Fog", "Joint Pain", "Weakness"]
    
    var onMoodSubmit: (() -> Void)? // Callback to update CalendarView
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("How are you feeling today?")
                        .font(.headline)
                    
                    HStack(spacing: 5) {
                        ForEach(0..<moodImages.count, id: \.self) { index in
                            Button(action: {
                                mood = index
                            }) {
                                Image(moodImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .background(mood == index ? Color.blue.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    Text("Selected Mood: \(moodDescriptions[mood])")
                        .font(.subheadline)
                    
                    Text("Symptoms")
                        .font(.headline)
                    
                    FlowLayout(items: symptomOptions, selectedItems: $symptoms)
                    
                    TextField("Additional Notes", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: saveMoodEntry) {
                        Text("Save Mood")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Mood Tracker")
        }
    }
    
    func saveMoodEntry() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Remove any existing mood entry for today before adding a new one
        moodStorage.moodEntries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: today) }
        
        let newEntry = MoodEntry(date: today, mood: mood, notes: notes, symptoms: symptoms)
        moodStorage.moodEntries.append(newEntry)
        
        // Explicitly trigger UI refresh
        DispatchQueue.main.async {
            moodStorage.objectWillChange.send()
            moodStorage.moodEntries = moodStorage.moodEntries
        }
        
        notes = ""  // Reset fields
        symptoms = []
        onMoodSubmit?()  // Notify CalendarView
        presentationMode.wrappedValue.dismiss()
    }
}

struct FlowLayout: View {
    let items: [String]
    @Binding var selectedItems: [String]
    
    var body: some View {
        WrapLayout(items: items, selectedItems: $selectedItems)
    }
}

struct WrapLayout: View {
    let items: [String]
    @Binding var selectedItems: [String]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 5) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedItems.contains(item) ? Color.blue.opacity(0.2) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .clipShape(Capsule())
                        .onTapGesture {
                            if selectedItems.contains(item) {
                                selectedItems.removeAll { $0 == item }
                            } else {
                                selectedItems.append(item)
                            }
                        }
                }
            }
            .padding()
        }
    }
}
