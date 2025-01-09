import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImageData: Data?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraController = CameraViewController()
        cameraController.capturedImageData = $capturedImageData
        return cameraController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var capturedImageData: Binding<Data?>?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available.")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = self.view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
        } catch {
            print("Error setting up camera: \(error)")
        }
        
        let captureButton = UIButton(frame: CGRect(x: self.view.frame.size.width / 2 - 35, y: self.view.frame.size.height - 100, width: 70, height: 70))
        captureButton.layer.cornerRadius = 35
        captureButton.backgroundColor = .red
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        self.view.addSubview(captureButton)
    }
    
    @objc func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let connection = photoOutput.connection(with: .video), connection.isEnabled {
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func captureOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhotoToSandboxedData photoData: Data?, error: Error?) {
        if let photoData = photoData {
            self.capturedImageData?.wrappedValue = photoData
        }
    }
}
