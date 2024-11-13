//
//  CameraViewModel.swift
//  BeHappy
//
//  Created by Francesco Paciello on 12/11/24.
//

import Foundation
import CoreImage
import Observation
import Combine

@Observable
class ViewModel {
    var currentFrame: CGImage?
    var prediction: String?
    private let cameraManager = CameraManager()
    private var cancellable: AnyCancellable? // Store the sink subscription

    
    init() {
        Task {
            await handleCameraPreviews()
        }
        
        cancellable = cameraManager.$predictionResult.sink { [weak self] result in
            Task { @MainActor in
                self?.prediction = result
            }
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}
