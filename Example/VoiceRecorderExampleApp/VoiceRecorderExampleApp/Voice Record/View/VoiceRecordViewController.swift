//
//  VoiceRecordViewController.swift
//  VoiceRecorderExampleApp
//
//  Created by berken on 6.09.2025.
//  
//

import UIKit
import voice_recorder_kit 

final class VoiceRecordViewController: UIViewController {
  private let speechRecordView = VoiceRecordView()

  var presenter: VoiceRecordPresentation!
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    speechRecordView.listenSpeechToTextManager()
  }
}

extension VoiceRecordViewController: VoiceRecordView {
  func setupUI() {
    speechRecordView.configure(languageCode: "tr-TR")
  }
}
