//
//  InstructionRow.swift
//  LegendaAR
//
//  Created by unimdp on 22/02/25.
//


import SwiftUI

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .foregroundColor(.white)
        }
    }
}