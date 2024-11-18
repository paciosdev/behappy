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
    var photoWasSaved: Bool = false
    var smileDurationCounter = -1
    let cameraManager = CameraManager()
    
    private var cancellablePrediction: AnyCancellable? // Store the sink subscription
    private var cancellableDuration: AnyCancellable? // Store the sink subscription
    private var cancellableSaved: AnyCancellable? // Store the sink subscription
    
    init() {
        Task {
            await handleCameraPreviews()
        }
        
        cancellablePrediction = cameraManager.$predictionResult.sink { [weak self] result in
            Task { @MainActor in
                self?.prediction = result
            }
        }
        
        cancellableDuration = cameraManager.$smileDurationCounter.sink { [weak self] result in
            Task { @MainActor in
                self?.smileDurationCounter = result
            }
        }
        
        cancellableSaved = cameraManager.$photoWasSaved.sink { [weak self] result in
            Task { @MainActor in
                self?.photoWasSaved = result
            }
        }
    }
    
    func stopSession() {
        cameraManager.stopSession()
    }

    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}
