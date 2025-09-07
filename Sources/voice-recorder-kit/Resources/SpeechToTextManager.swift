//
//  SpeechToTextManager.swift
//  Voice Record Kit
//
//  Created by berken on 30.07.2025.
//

import UIKit
import Speech

public enum SpeechRecognitionError: Error {
  case noSpeechDetected
  case unknown
  case languageNotSupported
  
  var localizedErrorDescription: String {
    switch self {
    case .noSpeechDetected:
      return "No Speech Detected"
    case .unknown:
      return "Unknown"
    case .languageNotSupported:
      return "Language not supported"
    }
  }
}

public final class SpeechToTextManager: NSObject, SFSpeechRecognizerDelegate {
  @MainActor static let shared = SpeechToTextManager()
  
  private var speechRecognizer: SFSpeechRecognizer?
  private lazy var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
  private lazy var audioEngine = AVAudioEngine()
  
  private var currentLanguage = "en-US"
  
  public var speechStarted: (() -> Void)?
  public var speechFinished: ((_ text: String) -> Void)?
  public var speechFailed: ((_ error: SpeechRecognitionError) -> Void)?
  public var audioLevelUpdated: ((Float) -> Void)?
  
  override private init() {
    super.init()
    
    setup()
  }
  
  private func setup() {}
  
  private func setupSpeechRecognizer(for languageCode: String) {
    speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: languageCode))
    speechRecognizer?.delegate = self
  }
  
  public func startSpeech(languageCode: String) {
    currentLanguage = languageCode
    
    setupSpeechRecognizer(for: languageCode)
    
    guard speechRecognizer?.isAvailable == true else {
      speechFailed?(.languageNotSupported)
      
      return
    }
    
    do {
      let avAudioSession = AVAudioSession.sharedInstance()
      try avAudioSession.setCategory(.playAndRecord, mode: .default, options: [
        .mixWithOthers,
        .allowBluetooth,
        .allowAirPlay,
        .allowBluetoothA2DP,
        .defaultToSpeaker
      ])
      try avAudioSession.setActive(true)
    } catch {}
    
    if audioEngine.isRunning {
      audioEngine.stop()
      
      recognitionRequest.endAudio()
    }
    
    let inputNode = audioEngine.inputNode
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    recognitionRequest.shouldReportPartialResults = true
    
    if inputNode.numberOfInputs > 0 {
      inputNode.removeTap(onBus: 0)
    }
    
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
      guard let self = self else { return }
      
      self.processAudioBuffer(buffer)
      self.recognitionRequest.append(buffer)
    }
    
    do {
      try audioEngine.start()
      speechStarted?()
    } catch {
      let nsError = error as NSError
      nsError.code == 1110 ? self.speechFailed?(.noSpeechDetected) : self.speechFailed?(.unknown)

      debugPrint("Audio Engine Error: \(error.localizedDescription)")
    }
  }
  
  public func stopSpeech(completion: (() -> Void)? = nil) {
    recognitionRequest.endAudio()
    audioEngine.stop()
    
    let inputNode = audioEngine.inputNode
    if inputNode.numberOfInputs > 0 {
      inputNode.removeTap(onBus: 0)
    }
    
    speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
      guard let self = self else { return }
      
      if let result = result, result.isFinal {
        self.speechFinished?(result.bestTranscription.formattedString)
      } else if let error = error {
        let nsError = error as NSError
        nsError.code == 1110 ? self.speechFailed?(.noSpeechDetected) : self.speechFailed?(.unknown)
        
        debugPrint("Recognition Error: \(error.localizedDescription)")
      }
      
      completion?()
    }
  }
  
  private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
    guard let channelData = buffer.floatChannelData?[0] else { return }
    
    let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
    
    let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(channelDataArray.count))
    
    let normalizedLevel = min(max(rms * 10, 0.0), 1.0)
    
    audioLevelUpdated?(normalizedLevel)
  }
}
