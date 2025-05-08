//
//  MedicationTrackerView.swift
//  Chiron
//
//  Created by ak on 2/13/25.
//

import SwiftUI
import UserNotifications

struct Medication: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dosage: String
    var times: [Date] // Multiple reminders per day
}

class MedicationStorage: ObservableObject {
    @Published var medications: [Medication] {
        didSet {
            saveMedications()
        }
    }
    
    init() {
        self.medications = UserDefaults.standard.loadMedications()
    }
    
    func saveMedications() {
        UserDefaults.standard.saveMedications(medications)
    }
}

extension UserDefaults {
    private static let medicationKey = "medications"
    
    func saveMedications(_ medications: [Medication]) {
        if let encoded = try? JSONEncoder().encode(medications) {
            set(encoded, forKey: UserDefaults.medicationKey)
        }
    }
    
    func loadMedications() -> [Medication] {
        if let savedData = data(forKey: UserDefaults.medicationKey), let decoded = try? JSONDecoder().decode([Medication].self, from: savedData) {
            return decoded
        }
        return []
    }
}

struct MedicationTrackerView: View {
    @StateObject private var medicationStorage = MedicationStorage()
    @State private var showingAddMedication = false
    
    var body: some View {
        NavigationView {
            VStack {
                if medicationStorage.medications.isEmpty {
                    Text("No medications added yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(medicationStorage.medications) { medication in
                            VStack(alignment: .leading) {
                                Text(medication.name)
                                    .font(.headline)
                                Text("Dosage: \(medication.dosage)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                ForEach(medication.times, id: \ .self) { time in
                                    Text("Time: \(time, style: .time)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: deleteMedication)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                
                Button(action: {
                    showingAddMedication = true
                }) {
                    Text("Add Medication")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink.opacity(0.7))
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Medication Tracker")
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView(medications: $medicationStorage.medications)
            }
            .onAppear {
                requestNotificationPermission()
                rescheduleAllNotifications()
            }
        }
    }
    
    func deleteMedication(at offsets: IndexSet) {
        medicationStorage.medications.remove(atOffsets: offsets)
    }
    /// ✅ **Requests notification permission from the user**
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else if granted {
                print("Notifications allowed!")
            } else {
                print("Notifications denied by the user.")
            }
        }
    }
    
    // Reschedules all notifications when the app starts or data changes
    func rescheduleAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // Clear existing notifications
        
        for medication in medicationStorage.medications {
            scheduleNotifications(for: medication) // Re-schedule all medications
        }
        
    }
    
    // Schedules notifications for a specific medication
    func scheduleNotifications(for medication: Medication) {
        for time in medication.times {
            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "Time to take \(medication.name) - \(medication.dosage)"
            content.sound = .default
            
            let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled for \(medication.name) at \(time)")
                }
            }
        }
    }
}

struct AddMedicationView: View {
    @Binding var medications: [Medication]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var times: [Date] = [Date()]
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage", text: $dosage)
                }
                
                Section(header: Text("Reminder Times")) {
                    ForEach(times.indices, id: \ .self) { index in
                        DatePicker("Time \(index + 1)", selection: $times[index], displayedComponents: .hourAndMinute)
                    }
                    
                    Button(action: {
                        times.append(Date())
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Another Time")
                        }
                    }
                    .foregroundColor(.pink)
                }
                
                Button(action: saveMedication) {
                    Text("Save Medication")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding()
                .disabled(name.isEmpty || dosage.isEmpty)
            }
            .navigationTitle("Add Medication")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Information"), message: Text("Please enter both the medication name and dosage."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func saveMedication() {
        if name.isEmpty || dosage.isEmpty {
            showAlert = true
            return
        }
        let newMedication = Medication(name: name, dosage: dosage, times: times)
        medications.append(newMedication)
        scheduleNotifications(for: newMedication)
        presentationMode.wrappedValue.dismiss()
    }
    
    func scheduleNotifications(for medication: Medication) {
        for time in medication.times {
            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "Time to take \(medication.name) - \(medication.dosage)"
            content.sound = .default
            
            let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
}

#Preview {
    MedicationTrackerView()
}
