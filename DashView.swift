//
//  DashView.swift
//  Chiron
//
//  Created by ak on 2/8/25.
//

import SwiftUI

struct DashView: View {
    let dashboardItems: [DashboardItem] = [
        // Spiral & Wave Tracking widget
        // Takes user to TestsView
        DashboardItem(title: "Spiral & Wave Tracking", subtitle: "Track tremor progression with drawing exercises.", imageName: "scribble.variable", color: Color(hex: "fb6f92"), destination: AnyView(TestsView())),
        
        // Mood Tracker widget
        // Takes user to CalendarView
        DashboardItem(title: "Mood Tracker", subtitle: "Log your daily mood and track changes over time.", imageName: "face.smiling", color: Color(hex: "FBAF6F"), destination: AnyView(CalendarView())),
        
        // Medication Tracker widget
        DashboardItem(title: "Medication", subtitle: "Manage your prescriptions and set reminders.", imageName: "pills.fill", color: Color(hex: "6FAAFB"), destination: AnyView(MedicationTrackerView())),
        
        // Dexterity game widget
        DashboardItem(title: "Dexterity Games", subtitle: "Improve hand control with interactive games.", imageName: "hand.raised.fill", color: Color(hex: "B26FFB"), destination: AnyView(DexterityGamesView()))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // subheading
                    Text("Track your progress and stay on top of your health.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                    
                    VStack(spacing: 15) {
                        ForEach(dashboardItems, id: \.title) { item in
                            NavigationLink(destination: item.destination) {
                                DashboardCard(item: item)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Dashboard")
        }
    }
}

struct DashboardItem {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
    let destination: AnyView
}

struct DashboardCard: View {
    let item: DashboardItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            
            Image(systemName: item.imageName)
                .font(.system(size: 30))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(item.color.gradient)
        .cornerRadius(15)
        .shadow(color: item.color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// Helper function to convert hex colors to SwiftUI Colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    DashView()
}
