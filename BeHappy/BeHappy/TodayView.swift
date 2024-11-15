//
//  TodayView.swift
//  BeHappy
//
//  Created by Francesco Paciello on 14/11/24.
//

import SwiftUI

struct TodayView: View {
    
    @State private var showCamera = false
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack{
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.main)
                
                
                VStack{
                    Spacer()
                    Text("You didn’t smile today!")
                        .padding(.horizontal)
                        .font(.system(size: 55, design: .rounded))
                        .bold()
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    
                    
                    Button(action: {
                        showCamera = true
                    }, label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                            
                            HStack{
                                Image(systemName: "face.smiling")
                                Text("Smile now")
                            }
                            .bold()
                            .foregroundStyle(.main)
                            .font(.title2)
                            
                            
                        }
                    })
                    .frame(width: 254, height: 59)
                    .padding(.bottom, 40)
                    .fullScreenCover(isPresented: $showCamera) {
                        CameraView(image: $viewModel.currentFrame, prediction: $viewModel.prediction, smileDurationCounter: $viewModel.smileDurationCounter)
                    }
                }
            }
            .frame(width: 336, height: 427)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "calendar")
                            .font(.title2)
                    }

                }
            }
        }
    }
}

#Preview {
    TodayView()
}
