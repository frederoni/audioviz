import AVFoundation
import Combine
import Foundation

public class AudioCaptureSession: NSObject {
    private let queue = DispatchQueue(label: "AudioCaptureSession")
    @Published public private(set) var audioSampleBuffer: CMSampleBuffer?
    @Published public private(set) var averagePowerLevels: [Float] = []
    @Published public private(set) var selectedAudioDevice: AVCaptureDevice?

    private let captureSession = AVCaptureSession()
    private let audioDataOutput = AVCaptureAudioDataOutput()
    private var audioDeviceInput: AVCaptureDeviceInput?

    override public init() {
        super.init()
        queue.async { [weak self] in
            guard let self else { return }
            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }

            audioDataOutput.setSampleBufferDelegate(self, queue: queue)
            if captureSession.canAddOutput(audioDataOutput) {
                captureSession.addOutput(audioDataOutput)
            } else {
                print("Could not add audioDataOutput: \(audioDataOutput)")
            }
        }
    }

    private func startIfNotRunning() {
        queue.async { [weak self] in
            guard let self else { return }
            guard !captureSession.isRunning else { return }
            captureSession.startRunning()
        }
    }

    private func stopIfRunning() {
        queue.async { [weak self] in
            guard let self else { return }
            guard captureSession.isRunning else { return }
            captureSession.stopRunning()
        }
    }

    public func switchAudioDevice(to captureDevice: AVCaptureDevice) {
        queue.async { [weak self] in
            guard let self else { return }

            let sameDevice = captureDevice == audioDeviceInput?.device
            guard !sameDevice else { return }

            self.stopIfRunning()
            defer { self.startIfNotRunning() }

            let newInput: AVCaptureDeviceInput
            do {
                newInput = try AVCaptureDeviceInput(device: captureDevice)
            } catch {
                print("Error creating audio AVCaptureDeviceInput: \(error)")
                return
            }

            captureSession.beginConfiguration()
            if let audioDeviceInput = audioDeviceInput {
                captureSession.removeInput(audioDeviceInput)
            }
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
                audioDeviceInput = newInput
            } else {
                print("Unable to add audio device input: \(captureDevice)")
            }
            captureSession.commitConfiguration()
            selectedAudioDevice = captureDevice
        }
    }
}

// MARK: AVCaptureAudioDataOutputSampleBufferDelegate

extension AudioCaptureSession: AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        averagePowerLevels = connection.audioChannels.map { $0.averagePowerLevel }
        audioSampleBuffer = sampleBuffer
    }
}
