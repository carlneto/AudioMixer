import SwiftUI
import AVFoundation

struct ContentView: View {
   @State private var audioFileOrignURL: URL?
   @State private var audioFileVoiceURL: URL?
   @State private var outputURL: URL?
   @State private var isMixing = false
   @State private var mixSuccess = false
   @State private var errorMessage: String?
   
   var body: some View {
      VStack {
         Text("Audio Mixer").font(.largeTitle).padding()
         
         HStack {
            Button("Selecionar Original") {
               selectAudioFile { url in
                  audioFileOrignURL = url
               }
            }
            Text(audioFileOrignURL?.lastPathComponent ?? "Nenhum ficheiro selecionado")
         }.padding()
         
         HStack {
            Button("Selecionar Voz") {
               selectAudioFile { url in
                  audioFileVoiceURL = url
               }
            }
            Text(audioFileVoiceURL?.lastPathComponent ?? "Nenhum ficheiro selecionado")
         }.padding()
         
         Button("Selecionar Destino & Misturar Áudios") {
            selectOutputURL { url in
               guard let audioFileOrignURL = audioFileOrignURL, let audioFileVoiceURL = audioFileVoiceURL else {
                  errorMessage = "Selecione ambos os ficheiros de áudio"
                  return
               }
               isMixing = true
               mixAudioFilesWithVolumeAdjustment(audioFileOrignURL: audioFileOrignURL, audioFileVoiceURL: audioFileVoiceURL, outputURL: url) { success, error in
                  DispatchQueue.main.async {
                     isMixing = false
                     mixSuccess = success
                     if let error = error {
                        errorMessage = error.localizedDescription
                     }
                  }
               }
            }
         }
         .padding()
         .disabled(isMixing)
         
         if isMixing {
            ProgressView("Misturando Áudios...")
         } else if mixSuccess {
            Text("Áudios misturados com sucesso!")
         } else if let errorMessage = errorMessage {
            Text("Erro: \(errorMessage)")
         }
      }
      .padding()
   }
   
   func mixAudioFilesWithVolumeAdjustment(audioFileOrignURL: URL, audioFileVoiceURL: URL, outputURL: URL, completion: @escaping (Bool, Error?) -> Void) {
      let audioAssetOrign = AVAsset(url: audioFileOrignURL)
      let audioAssetVoice = AVAsset(url: audioFileVoiceURL)
      let composition = AVMutableComposition()
      guard let audioTrackOrign = audioAssetOrign.tracks(withMediaType: .audio).first,
            let audioTrackVoice = audioAssetVoice.tracks(withMediaType: .audio).first,
            let compositionAudioTrackOrign = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid),
            let compositionAudioTrackVoice = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
         completion(false, NSError(domain: "MixAudioError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Não foi possível carregar ou adicionar as faixas de áudio"]))
         return
      }
      do {
         try compositionAudioTrackOrign.insertTimeRange(CMTimeRange(start: .zero, duration: audioAssetOrign.duration), of: audioTrackOrign, at: .zero)
         try compositionAudioTrackVoice.insertTimeRange(CMTimeRange(start: .zero, duration: audioAssetVoice.duration), of: audioTrackVoice, at: .zero)
      } catch {
         completion(false, error)
         return
      }
      let audioMix = AVMutableAudioMix()
      let parameters = AVMutableAudioMixInputParameters(track: compositionAudioTrackOrign)
      let silenceThreshold: Float = -50.0
      guard let assetReader = try? AVAssetReader(asset: audioAssetVoice) else {
         completion(false, NSError(domain: "MixAudioError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Não foi possível criar o leitor de AVAsset"]))
         return
      }
      let trackOutputSettings: [String: Any] = [
         AVFormatIDKey: kAudioFormatLinearPCM,
         AVLinearPCMIsFloatKey: false,
         AVLinearPCMBitDepthKey: 16,
         AVLinearPCMIsBigEndianKey: false,
         AVLinearPCMIsNonInterleaved: false
      ]
      let trackOutput = AVAssetReaderTrackOutput(track: audioTrackVoice, outputSettings: trackOutputSettings)
      assetReader.add(trackOutput)
      assetReader.startReading()
      var currentTime = CMTime.zero
      while assetReader.status == .reading {
         if let sampleBuffer = trackOutput.copyNextSampleBuffer(),
            let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
            var length = 0
            var dataPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
            if let dataPointer = dataPointer {
               let data = Data(bytes: dataPointer, count: length)
               let samples = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> [Int16] in
                  let bufferPointer = ptr.bindMemory(to: Int16.self)
                  return Array(bufferPointer)
               }
               let samples_map = samples.map { Float($0) * Float($0) }.reduce(0, +) / Float(samples.count)
               let rms = sqrt(samples_map)
               let db = 20.0 * log10(rms)
               let duration = CMSampleBufferGetDuration(sampleBuffer)
               if db > silenceThreshold {
                  parameters.setVolume(0.05, at: currentTime)
               } else {
                  parameters.setVolume(1.0, at: currentTime)
               }
               currentTime = CMTimeAdd(currentTime, duration)
            }
         }
      }
      if assetReader.status == .failed || assetReader.status == .cancelled {
         completion(false, assetReader.error)
         return
      }
      audioMix.inputParameters = [parameters]
      guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
         completion(false, NSError(domain: "MixAudioError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Não foi possível criar o exportador de AVAsset"]))
         return
      }
      exporter.outputURL = outputURL
      exporter.outputFileType = .m4a
      exporter.audioMix = audioMix
      exporter.exportAsynchronously {
         switch exporter.status {
            case .completed:
               completion(true, nil)
            case .failed, .cancelled:
               completion(false, exporter.error)
            default:
               break
         }
      }
   }
   
   func selectAudioFile(completion: @escaping (URL) -> Void) {
      let panel = NSOpenPanel()
      panel.allowedFileTypes = ["aiff", "m4a", "mp3", "wav"]
      panel.begin { response in
         if response == .OK, let url = panel.url {
            completion(url)
         }
      }
   }
   
   func selectOutputURL(completion: @escaping (URL) -> Void) {
      let panel = NSOpenPanel()
      panel.canChooseDirectories = true
      panel.canCreateDirectories = true
      panel.canChooseFiles = false
      panel.begin { response in
         if response == .OK {
            self.outputURL = panel.url
            guard let url = outputURL?.appendingPathComponent("mixedAudio.m4a") else {
               errorMessage = "Não foi possível criar a url de destino"
               return
            }
            completion(url)
         }
      }
   }
}
