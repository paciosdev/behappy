//
//  ContentView.swift
//  BeHappy
//
//  Created by Angel Adrian Pimienta Flores on 12/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        CameraView(image: $viewModel.currentFrame, prediction: $viewModel.prediction)
    }
}

#Preview {
    ContentView()
}
