//
//  PhotoPreview.swift
//  BeHappy
//
//  Created by Francesco Paciello on 18/11/24.
//

import SwiftUI

struct PhotoPreview: View {
    
    let viewModel: ViewModel
    let image: UIImage
    @Binding var photoWasSaved: Bool
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        ZStack(alignment: .bottom){
            Image(uiImage: image)
                .resizable()
            
                .scaledToFill()
                
            
            Button {
                photoWasSaved = false
                mode.wrappedValue.dismiss()
            } label: {
                VStack{
                    ZStack {
                        GlassView()  
                            HStack{
                                Image(systemName: "arrow.circlepath")
                                Text("Retake...")
                                    .fontDesign(.rounded)
                            }
                    }
                    
                    Text("only 1 left")
                        .font(.caption)
                        .shadow(radius: 10)
                }
            }
            .foregroundStyle(.white)
            .padding(.bottom, 50)

        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            
    }
}

#Preview {
    PhotoPreview(viewModel: ViewModel(), image: UIImage(named: "notHappy")!, photoWasSaved: .constant(true))
}
