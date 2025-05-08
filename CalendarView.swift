//
//  CalendarView.swift
//  Chiron
//
//  Created by ak on 2/11/25.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject private var moodStorage = MoodStorage()
    @State private var selectedDate: Date? = Date()
    @State private var showingDetails = false
    @State private var navigateToMoodTrack = false
    @State private var currentMonth: Date = Date()
    
    // Refer to assets to preview the images
    let moodImages = ["very_sad", "sad", "neutral", "happy", "very_happy"]
    let moodDescriptions = ["Very Sad", "Sad", "Neutral", "Happy", "Very Happy"]
    
    // Loads example mood and symptom data into the calendar
    func preloadExampleMoodData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var exampleEntries = moodStorage.moodEntries
        
        for dayOffset in -100...(-1) { // Generate fake data for the last 10 days
            if let pastDate = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                let normalizedDate = calendar.startOfDay(for: pastDate)
                
                // Skip if an entry already exists for this date
                if exampleEntries.contains(where: { calendar.isDate($0.date, inSameDayAs: normalizedDate) }) {
                    continue
                }
                
                let fakeEntry = MoodEntry(
                    date: normalizedDate,
                    mood: Int.random(in: 0..<5),
                    notes: "Example note for \(pastDate.formatted(.dateTime))",
                    symptoms: ["Fatigue", "Anxiety"].shuffled().prefix(Int.random(in: 0...2)).map { $0 }
                )
                exampleEntries.append(fakeEntry)
            }
        }
        
        // Update mood storage only if new example data was added
        if exampleEntries.count > moodStorage.moodEntries.count {
            moodStorage.moodEntries = exampleEntries
        }
    }
    
    func getMoodData(for month: Date) -> [Date: Int?] {
        let calendar = Calendar.current
        let filteredEntries = moodStorage.moodEntries.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
        
        var data = [Date: Int?]()
        for entry in filteredEntries {
            let day = calendar.startOfDay(for: entry.date)
            data[day] = entry.mood
        }
        return data
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Button to press for an information pop-up
                ExtractView(fieldText: "Click for Instructions",fieldInfo: """
                • Tap on a past date to view your mood details.
                • Tap “Track Today’s Mood” to log a new mood entry.
                • Future dates cannot be selected and remain locked.
                • Scroll through months using the left and right arrows.
                """)
                .padding()
                
                HStack {
                    // Lets the user toggle to the left to see past months
                    Button(action: {
                        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
                            currentMonth = newMonth
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Displays the current month
                    Text(currentMonth, formatter: monthFormatter)
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    // Lets the user toggle to the right to see future months
                    Button(action: {
                        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
                            currentMonth = newMonth
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                .padding()
                
                CalendarGrid(
                    moodData: getMoodData(for: currentMonth),
                    selectedDate: $selectedDate,
                    showingDetails: $showingDetails,
                    navigateToMoodTrack: $navigateToMoodTrack,
                    moodStorage: moodStorage,
                    moodImages: moodImages,
                    currentMonth: currentMonth)
                .padding()
                
                // Takes the user to MoodTrackView so that they can track their mood for the day
                Button(action: {
                    navigateToMoodTrack = true
                }) {
                    Text("Track Today's Mood")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink.opacity(0.7))
                        .cornerRadius(10)
                        .padding()
                }
            }
            .onAppear {
                preloadExampleMoodData()  // Ensure example data loads before user taps
                /*
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    moodStorage.objectWillChange.send() // Force UI refresh
                }*/
            }
            .sheet(isPresented: $showingDetails) {
                if let selectedDate = selectedDate {
                    let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
                    
                    let entry = moodStorage.moodEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) })
                    
                    MoodDetailsView(entry: entry ?? MoodEntry(date: normalizedDate, mood: 2, notes: "No mood recorded yet.", symptoms: []))
                }
                else{
                    
                    let entry1=MoodEntry(date: Date(), mood: 2, notes: "No mood recorded yet.", symptoms: [])
                    MoodDetailsView(entry: entry1)
                }
            }
            .sheet(isPresented: $navigateToMoodTrack) {
                MoodTrackView(moodStorage: moodStorage, onMoodSubmit: {
                    navigateToMoodTrack = false
                    
                    // Ensure today’s entry updates in CalendarView
                    DispatchQueue.main.async {
                        moodStorage.objectWillChange.send()
                        moodStorage.moodEntries = moodStorage.moodEntries
                    }
                })
            }
        }
    }
}

struct CalendarGrid: View {
    let moodData: [Date: Int?]
    @Binding var selectedDate: Date?
    @Binding var showingDetails: Bool
    @Binding var navigateToMoodTrack: Bool
    @ObservedObject var moodStorage: MoodStorage
    let moodImages: [String]
    let currentMonth: Date
    let calendar = Calendar.current
    
    var body: some View {
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(0..<daysInMonth, id: \.self) { day in
                if let date = calendar.date(byAdding: .day, value: day, to: startOfMonth) {
                    let moodIndex = moodData[date] ?? nil
                    let dayNumber = calendar.component(.day, from: date) // Extract day of the month
                    let isToday = calendar.isDate(date, inSameDayAs: Date())
                    
                    
                    VStack(spacing: 3) { // Stack mood image and day number
                        if date <= Calendar.current.startOfDay(for: Date()) { // Only clickable for past/present days
                            Button(action: {
                                let today = Calendar.current.startOfDay(for: Date())
                                let selectedDay = Calendar.current.startOfDay(for: date)
                                
                                // If user clicks on today but hasn't logged a mood, go to Mood Tracker
                                if selectedDay == today && !moodStorage.moodEntries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                                    print("📌 No mood entry for today, opening MoodTrackView")
                                    navigateToMoodTrack = true
                                    return
                                }
                                
                                selectedDate = date
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Small delay to allow data to update
                                    moodStorage.objectWillChange.send()
                                    showingDetails = true
                                }
                                
                            }) {
                                if let moodIndex = moodIndex {
                                    Image(moodImages[moodIndex])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .background(isToday ? Color.blue.opacity(0.3) : Color.clear)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(isToday ? Color.blue.opacity(0.3) : Color(UIColor.systemGray4))
                                        .frame(width: 40, height: 40)
                                }
                            }
                        } else { // Future dates are unclickable
                            Circle()
                                .fill(Color(UIColor.systemGray4)) // Keep gray for future dates
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "lock.fill") // Optional lock icon
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                )
                        }
                        
                        Text("\(dayNumber)") // Display the day number below the circle
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct MoodDetailsView: View {
    let entry: MoodEntry
    let moodImages = ["very_sad", "sad", "neutral", "happy", "very_happy"]
    let moodDescriptions = ["Very Sad", "Sad", "Neutral", "Happy", "Very Happy"]
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Mood Details")
                .font(.title)
                .bold()
            
            Text("\(entry.date, style: .date)")
                .font(.headline)
            
            Image(moodImages[entry.mood]) // Use actual mood image
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            
            Text("Mood: \(moodDescriptions[entry.mood])")
                .font(.headline)
            
            if !entry.symptoms.isEmpty {
                
                Text("Symptoms: \(entry.symptoms.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            if !entry.notes.isEmpty {
                Text("Notes: \(entry.notes)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            // Lets the user close the pop-up sheet of the details from that day
            Button("Close") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}


let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()

#Preview {
    CalendarView()
}
