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
    
    var smileDurationCounter = -1
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
        
        cancellable = cameraManager.$smileDurationCounter.sink { [weak self] result in
            Task { @MainActor in
                self?.smileDurationCounter = result
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
