//
//  loadingScreenView.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 1/29/25.
//

import SwiftUI

struct loadingScreenViewUI: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        
        ZStack {
            Color(red: 0.4, green: 0.4, blue: 0.9)
                .ignoresSafeArea()
            Image("Untitled-2-removebg-preview")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .scaleEffect(scale)
                .animation(Animation.easeInOut(duration: 0.75).repeatForever(autoreverses: true), value: scale)
                .onAppear {
                    scale = 1.1
                }
        }
    }
}


#Preview {
    loadingScreenViewUI()
}
