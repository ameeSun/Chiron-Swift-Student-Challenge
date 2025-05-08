//
//  TreatmentView.swift
//  Chiron
//
//  Created by ak on 2/21/25.
//

import SwiftUI

struct TreatmentView: View {
    
    let treatmentItems: [String] = [
        "Increasing the level of dopamine in the brain",
        "Having an effect on other brain chemicals, such as neurotransmitters, which transfer information between brain cells",
        "Helping control non-movement symptoms"
    ]
    
    let otherMedications: [String] = [
        "Dopamine agonists to stimulate the production of dopamine in the brain",
        "Enzyme inhibitors (e.g., MAO-B inhibitors, COMT inhibitors) to increase the amount of dopamine by slowing down the enzymes that break down dopamine in the brain",
        "Amantadine to help reduce involuntary movements",
        "Anticholinergic drugs to reduce tremors and muscle rigidity"
    ]
    
    let otherTherapies: [String] = [
        "Physical, occupational, and speech therapies, which may help with gait and voice disorders, tremors and rigidity, and decline in mental functions",
        "A healthy diet to support overall wellness",
        "Exercises to strengthen muscles and improve balance, flexibility, and coordination",
        "Massage therapy to reduce tension",
        "Yoga and tai chi to increase stretching and flexibility"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Image("pdmeds")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Section {
                    Text("Medicines can help treat the symptoms of Parkinson’s by:")
                        .font(.callout)
                        .fontWeight(.medium)
                    Text(treatmentItems.toBulletList()) // ✅ Now using pre-declared list
                        .font(.callout)
                }
                
                Section {
                    Text("The main therapy for Parkinson’s is levodopa. Nerve cells use levodopa to make dopamine to replenish the brain’s dwindling supply. Usually, people take levodopa along with another medication called carbidopa. Carbidopa prevents or reduces some of the side effects of levodopa therapy — such as nausea, vomiting, low blood pressure, and restlessness — and reduces the amount of levodopa needed to improve symptoms.\n\nPeople living with Parkinson’s disease should never stop taking levodopa without telling their doctor. Suddenly stopping the drug may have serious side effects, like being unable to move or having difficulty breathing.")
                        .font(.callout)
                } header: {
                    Text("Levodopa")
                }
                
                Section {
                    Text("The doctor may prescribe other medicines to treat Parkinson’s symptoms, including:")
                        .font(.callout)
                        .fontWeight(.medium)
                    Text(otherMedications.toBulletList()) // ✅ Pre-defined medication list
                        .font(.callout)
                } header: {
                    Text("Other Medications")
                }
                
                Section {
                    Text("For people with Parkinson’s disease who do not respond well to medications, the doctor may recommend deep brain stimulation. During a surgical procedure, a doctor implants electrodes into part of the brain and connects them to a small electrical device implanted in the chest. The device and electrodes painlessly stimulate specific areas in the brain that control movement in a way that may help stop many of the movement-related symptoms of Parkinson’s, such as tremor, slowness of movement, and rigidity.")
                        .font(.callout)
                } header: {
                    Text("Deep Brain Stimulation")
                }
                
                Section {
                    Text("Other therapies that may help manage Parkinson’s symptoms include:")
                        .font(.callout)
                        .fontWeight(.medium)
                    Text(otherTherapies.toBulletList())
                        .font(.callout)
                } header: {
                    Text("Other Therapies")
                }
            }
            .navigationBarTitle("Treatment")
        }
    }
}

#Preview {
    TreatmentView()
}

extension Array where Element == String {
    func toBulletList() -> String {
        self.map { "• \($0)" }.joined(separator: "\n")
    }
}
