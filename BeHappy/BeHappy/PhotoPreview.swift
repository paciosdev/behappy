//
//  PhotoPreview.swift
//  BeHappy
//
//  Created by Francesco Paciello on 18/11/24.
//

import SwiftUI
import AVFoundation

struct PhotoPreview: View {
    
    let viewModel: ViewModel
    let image: UIImage
    @Binding var photoWasSaved: Bool
    @Environment(\.presentationMode) var mode
    @State var player: AVAudioPlayer? = AVAudioPlayer()
    @State private var vibrate = false
    
    var cgImage: CGImage? {
        guard let ciImage = CIImage(image: self.image) else {
            return nil
        }
        
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    var body: some View {
        ZStack(alignment: .bottom){
            
         
            if let cgImage{
                Image(decorative: cgImage, scale: 1, orientation: .leftMirrored)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
                
            
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
        .onAppear {
            guard let soundURL = Bundle.main.url(forResource: "cika", withExtension: "m4a") else {
              return
            }

            do {
                self.player = try AVAudioPlayer(contentsOf: soundURL)
            } catch {
              print("Failed to load the sound: \(error)")
            }
            player?.play()
            vibrate = true
        }
        

            
    }
}

#Preview {
    PhotoPreview(viewModel: ViewModel(), image: UIImage(named: "notHappy")!, photoWasSaved: .constant(true))
}
