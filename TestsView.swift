//
//  TestsView.swift
//  Chiron
//
//  Created by ak on 2/8/25.
//

import SwiftUI
import PencilKit

struct TestsView: View {
    
    var body: some View {
        List {
            HStack(){
                Image(systemName: "circle.circle")
                    .foregroundColor(Color(.systemPink))
                NavigationLink("Spiral Test"){
                    SpiralView()
                }
                .padding()
            }
            HStack(){
                Image(systemName: "waveform.path")
                    .foregroundColor(Color(.systemPink))
                NavigationLink("Wave Test"){
                    WaveView()
                }
                .padding()
            }
        }
        .navigationTitle("Select Test to Perform")
    }
    
}

#Preview {
    TestsView()
}
