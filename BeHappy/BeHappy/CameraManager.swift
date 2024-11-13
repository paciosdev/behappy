import Foundation
import AVFoundation
import CoreML
import Vision
import SwiftUI

class CameraManager: NSObject {
    
    private let captureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let systemPreferredCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private var sessionQueue = DispatchQueue(label: "video.preview.session")
    
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    private var addToPreviewStream: ((CGImage) -> Void)?
    lazy var previewStream: AsyncStream<CGImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage in
                continuation.yield(cgImage)
            }
        }
    }()
    
    // ML Model and prediction-related variables
    private var frameCounter = 0
    private let model: VNCoreMLModel? = {
        // Load your CoreML model
        guard let model = try? BeHappy(configuration: MLModelConfiguration()).model else {
            print("Failed to load the model")
            return nil
        }
        return try? VNCoreMLModel(for: model)
    }()
    
    private let predictionQueue = DispatchQueue(label: "com.behappy.predictionQueue")
    @Published var predictionResult: String? // Published to bind with CameraView
    
    private var smileTimer: Timer?
    private var timerStartDate: Date?
    private let smileDuration: TimeInterval = 3.0 // Duration to detect a sustained smile
    private var isCapturingPhoto = false
    
    override init() {
        super.init()
        
        Task {
            await configureSession()
            await startSession()
        }
    }
    
    private func configureSession() async {
        guard await isAuthorized,
              let systemPreferredCamera,
              let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
        else { return }
        
        captureSession.beginConfiguration()
        defer { self.captureSession.commitConfiguration() }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        guard captureSession.canAddInput(deviceInput), captureSession.canAddOutput(videoOutput) else {
            print("Unable to add input/output to capture session.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)
    }
    
    private func startSession() async {
        guard await isAuthorized else { return }
        captureSession.startRunning()
    }
    
    private func performPrediction(for cgImage: CGImage) {
        predictionQueue.async {
            let request = VNCoreMLRequest(model: self.model!) { [weak self] request, _ in
                guard let observations = request.results as? [VNClassificationObservation],
                      let bestResult = observations.first else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.handlePredictionResult(bestResult.identifier, cgImage: cgImage)
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
    
    private func handlePredictionResult(_ result: String, cgImage: CGImage) {
        predictionResult = result
        
        if result == "smile" {
            if smileTimer == nil {
                // Start a new timer if one isn't already running
                timerStartDate = Date()
                smileTimer = Timer.scheduledTimer(withTimeInterval: smileDuration, repeats: false) { [weak self] _ in
                    self?.capturePhoto(cgImage)
                    self?.smileTimer = nil
                }
            }
        } else {
            // Reset the timer if the user stops smiling
            smileTimer?.invalidate()
            smileTimer = nil
            timerStartDate = nil
        }
    }
    
    private func capturePhoto(_ cgImage: CGImage) {
        guard !isCapturingPhoto else { return }
        isCapturingPhoto = true
        
        let uiImageFromCGImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        UIImageWriteToSavedPhotosAlbum(uiImageFromCGImage, nil, nil, nil)
        
        // Reset capturing state
        isCapturingPhoto = false
        print("Photo saved.")
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let currentFrame = sampleBuffer.cgImage else { return }
        
        addToPreviewStream?(currentFrame)
        // Increment the frame counter and perform inference every 5th frame
        frameCounter += 1
        if frameCounter % 5 == 0 {
            frameCounter = 0 // Reset counter
            detectFaces(in: currentFrame)
        }
    }
    
    private func detectFaces(in image: CGImage) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results as? [VNFaceObservation], error == nil else {
                print("Face detection error: \(String(describing: error))")
                return
            }
            
            if results.isEmpty {
                print("No face detected")
            } else {
                // Process detected faces
                for _ in results {
                    //print("Detected face at \(faceObservation.boundingBox)")
                    self.performPrediction(for: image)
                }
            }
            
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try requestHandler.perform([faceDetectionRequest])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
}
