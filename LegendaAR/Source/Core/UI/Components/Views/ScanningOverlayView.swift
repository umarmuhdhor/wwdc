//
//  ScanningOverlayView.swift
//  LegendaAR
//
//  Created by unimdp on 22/02/25.
//


import SwiftUI

struct ScanningOverlayView: View {
    var body: some View {
        VStack {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text("Point your camera at a flat surface")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
        }
    }
}