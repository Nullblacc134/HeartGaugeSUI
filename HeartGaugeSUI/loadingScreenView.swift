//
//  loadingScreenView.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 1/29/25.
//

import SwiftUI

struct HeartbeatLoadingView: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack {
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
    HeartbeatLoadingView()
}
