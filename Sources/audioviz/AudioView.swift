import SwiftTUI
import AVFoundation
import Combine

let minDB: Float = -50.0
let maxDB: Float = 0.0
var cancellables = Set<AnyCancellable>()
var captureDevices: [AVCaptureDevice] = AVCaptureDevice.DiscoverySession(
    deviceTypes: [.microphone, .external],
    mediaType: .audio, position: .unspecified
).devices.filter { $0.isConnected }
let captureSession = AudioCaptureSession()

struct AudioView: View {
    
    @State var averagePowerLevels: [Float] = []
    @State var audioLevels: [Int] = []
    @State var selectedDeviceName: String? {
        didSet {
            cancellables.removeAll()
            let captureDevice = captureDevices.first(where: { $0.localizedName == selectedDeviceName })!
            captureSession.switchAudioDevice(to: captureDevice)
            captureSession.$averagePowerLevels
                .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
                .receive(on: DispatchQueue.main)
                .sink { values in
                    averagePowerLevels = values
                    audioLevels = values.map { _ in Int.random(in: 0..<100) }
                }.store(in: &cancellables)
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                ForEach(0..<captureDevices.count, id: \.self) { i in
                    let device = captureDevices[i]
                    let isSelected = selectedDeviceName == device.localizedName
                    Button("\(isSelected ? "✅ " : "")\(device.localizedName)") {
                        selectedDeviceName = device.localizedName
                        RunLoop.current.run()
                    }
                }
            }.border()
            VStack {
                ForEach(0..<averagePowerLevels.count, id: \.self) { index in
                    let averagePowerLevel = averagePowerLevels[index]
                    HStack {
                        Text("Channel \(index + 1) \(averagePowerLevel)")
                    }
                }
            }
            .frame(width: 100)
            .border()
        }
        .border()
    }
}
