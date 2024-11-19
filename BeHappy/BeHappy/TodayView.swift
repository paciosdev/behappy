//
//  TodayView.swift
//  BeHappy
//
//  Created by Francesco Paciello on 14/11/24.
//

import SwiftUI


struct TodayView: View {
    
    @State private var showCamera = false
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Text(todayDate)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
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
                            CameraView()
                        }
                    }
                }
                .frame(width: 336, height: 427)
                .navigationTitle("Today")
                .fontDesign(.rounded)

                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            
                        } label: {
                            Image(systemName: "calendar")
                                .foregroundStyle(.main)
                                .bold()
                        }

                    }
                }
                .padding(.top, 80)
                
                Spacer()
            }
        }
    }
    
    var todayDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "en_US") // Adjust locale if needed
            let formattedDate = formatter.string(from: Date())
            // Extract only the day and month
            let components = formattedDate.split(separator: " ")
            if components.count >= 2 {
                return "\(components[1]) \(components[0])" // "December 19" to "19 December"
            }
            return formattedDate
        }
}

#Preview {
    TodayView()
}
