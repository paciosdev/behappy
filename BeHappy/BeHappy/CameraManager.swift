import Foundation
import AVFoundation
import CoreML
import Vision

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
                    self?.predictionResult = bestResult.identifier
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
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
            performPrediction(for: currentFrame)
            detectFaces(in: currentFrame)

        }
    }
    
    private func detectFaces(in image: CGImage) {
            let faceDetectionRequest = VNDetectFaceRectanglesRequest { request, error in
                guard let results = request.results as? [VNFaceObservation], error == nil else {
                    print("Face detection error: \(String(describing: error))")
                    return
                }
                
                // Process detected faces
                for faceObservation in results {
                    print("Detected face at \(faceObservation.boundingBox)")
                    // You can draw rectangles around faces here or update the UI
                    
                    //do ml stuffs
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
