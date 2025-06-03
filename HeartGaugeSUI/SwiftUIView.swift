//
//  SwiftUIView.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 5/9/25.
import SwiftUI

struct SwiftUIView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    var body: some View {
        if isActive {
            ContentViewUI(signOut: {})
        }else{
            
            
            ZStack {
                Color(red: 0.4, green: 0.4, blue: 0.9)
                    .ignoresSafeArea()
                
                VStack(spacing: 20){
                    
                    Image("Untitled-2-removebg-preview")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)
                    
                    Text("HeartGauge")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .onAppear{
                    withAnimation(.easeIn(duration: 1.2)){
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    withAnimation{
                        self.isActive = true
                    }
                }
            }
        }
    }
}
    #Preview {
        SwiftUIView()
    }

