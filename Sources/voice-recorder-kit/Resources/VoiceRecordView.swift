//
//  VoiceRecordView.swift
//  Voice Record Kit
//
//  Created by berken on 29.07.2025.
//

import UIKit
import SnapKit

public final class VoiceRecordView: UIView {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var liveWaveFormView: LiveWaveformView!
  
  private var isRecording = false
  private var languageCode = ""
  
  public var onSpeechRecognized: ((String) -> Void)?
  public var onRecordingStateChanged: ((Bool) -> Void)?
  public var onSpeechFailed: ((SpeechRecognitionError) -> Void)?
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    
    loadNib()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    loadNib()
  }
  
  private func loadNib() {
    Bundle.module.loadNibNamed("VoiceRecordView", owner: self, options: nil)
    addSubview(contentView)
    
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.layer.masksToBounds = true
  }
  
  public func configure(in containerView: UIView, languageCode: String) {
    self.languageCode = languageCode
    
    containerView.addSubview(self)
    
    listenSpeechToTextManager()
    
    isHidden = false
    alpha = 1
    
    liveWaveFormView.isHidden = true
    liveWaveFormView.waveColor = .blue
    liveWaveFormView.waveWidth = 3.0
    liveWaveFormView.waveSpacing = 2.0
    
    snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  public func updateLanguage(_ languageCode: String) {
    self.languageCode = languageCode
  }
  
  public func hide() {
    stopRecording()
    
    removeFromSuperview()
  }
  
  public func updateUI(isRecording: Bool) {
    if isRecording {
      liveWaveFormView?.startAnimating()
      liveWaveFormView.isHidden = false
      
      startRecording()
    } else {
      liveWaveFormView?.stopAnimating()
      liveWaveFormView.isHidden = true
      
      stopRecording()
    }
  }
  
  public func listenSpeechToTextManager() {
    let manager = SpeechToTextManager.shared
    
    manager.speechStarted = { [weak self] in
      self?.updateUI(isRecording: true)
    }
    
    manager.speechFinished = { [weak self] text in
      self?.onSpeechRecognized?(text)
      
      self?.updateUI(isRecording: false)
    }
    
    manager.speechFailed = { [weak self] error in
      self?.onSpeechFailed?(error)
      
      self?.updateUI(isRecording: false)
    }
    
    manager.audioLevelUpdated = { [weak self] level in
      DispatchQueue.main.async { [weak self] in
        self?.liveWaveFormView?.updateWithAudioLevel(level)
      }
    }
  }
  
  private func startRecording() {
    guard !isRecording else { return }
    
    isRecording = true
    
    onRecordingStateChanged?(true)
    
    liveWaveFormView?.startAnimating()
    
    SpeechToTextManager.shared.startSpeech(languageCode: languageCode)
  }
  
  private func stopRecording() {
    guard isRecording else { return }
    
    isRecording = false
    
    onRecordingStateChanged?(false)
    
    liveWaveFormView?.stopAnimating()
    
    SpeechToTextManager.shared.stopSpeech()
  }
}
