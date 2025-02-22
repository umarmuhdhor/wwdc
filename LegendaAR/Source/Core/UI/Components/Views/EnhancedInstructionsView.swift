//
//  EnhancedInstructionsView.swift
//  LegendaAR
//
//  Created by unimdp on 22/02/25.
//


import SwiftUI

struct EnhancedInstructionsView: View {
    let dismissAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            
            VStack(spacing: 20) {
                Text("How to Build Your Ship")
                    .font(.title)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 15) {
                    InstructionRow(number: 1, text: "Point your camera at a flat surface")
                    InstructionRow(number: 2, text: "Wait for the ship outline to appear")
                    InstructionRow(number: 3, text: "Select a ship part from the bottom menu")
                    InstructionRow(number: 4, text: "Tap the outline where the part should go")
                    InstructionRow(number: 5, text: "Complete the ship by placing all parts")
                }
                .padding()
                
                Button("Start Building") {
                    dismissAction()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}