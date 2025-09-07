//
//  VoiceRecordPresenter.swift
//  VoiceRecorderExampleApp
//
//  Created by berken on 6.09.2025.
//  
//

import Foundation

final class VoiceRecordPresenter {
  weak var view: VoiceRecordView?
  var router: VoiceRecordWireframe!
  var interactor: VoiceRecordInteractorInput!
}

extension VoiceRecordPresenter: VoiceRecordPresentation {
  func viewDidLoad() {
    view?.setupUI()
  }
}

extension VoiceRecordPresenter: VoiceRecordInteractorOutput {}
