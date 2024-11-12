//
//  CameraView.swift
//  BeHappy
//
//  Created by Angel Adrian Pimienta Flores on 11/11/24.
//

import SwiftUI

struct CameraView: View {
    
    let gradientSurface = LinearGradient(colors: [.yellow, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let gradientBorder = LinearGradient(colors: [.yellow.opacity(0.5), .white.opacity(0.1), .black.opacity(0.1), .yellow.opacity(0.1), .yellow.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        ZStack {
            Image("notHappy")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Text("Smile")
                    .font(.system(size:100))
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.ultraThinMaterial)
                    .mask(
                        Text("Smile")
                            .font(.system(size:100))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.yellow)
                    )
                    .overlay(
                        Text("Smile")
                            .font(.system(size:100))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundStyle(gradientBorder)
                            .opacity(0.8)
                    )
                    .shadow(radius: 5)
                    .opacity(0.8)
                
                Spacer()
                Button{
                    
                }label:{
                    ZStack{
                        GlassView()
                        Text("Remind Me Later...")
                            .fontDesign(.rounded)

                        
                    }
                }
                .foregroundStyle(.white)
            }
        }
    }
}

struct GlassView: View {
    let gradientSurface = LinearGradient(colors: [.black.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
    let gradientBorder = LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.0), .black.opacity(0.0), .green.opacity(0.0), .yellow.opacity(0.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 500, style: .continuous)
            .foregroundStyle(gradientSurface)
            .background(.ultraThinMaterial)
        
            .mask( RoundedRectangle(cornerRadius: 500,
                   style: .circular).foregroundColor(.black) )
            .overlay(
                RoundedRectangle(cornerRadius: 500, style: .circular)
                    .stroke(lineWidth: 1.5)
                    .foregroundStyle(gradientBorder)
                    .opacity(0.8)
            )
            .frame(width: 200, height: 50)
            .shadow(color: .black.opacity(0.25),
                    radius: 5, x: 0, y: 8)
    }
}

#Preview {
    CameraView()
}
