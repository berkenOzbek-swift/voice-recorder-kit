//
//  VoiceRecordContract.swift
//  VoiceRecorderExampleApp
//
//  Created by berken on 6.09.2025.
//  
//

import Foundation

protocol VoiceRecordView: AnyObject {
  func setupUI()
}

protocol VoiceRecordPresentation: AnyObject {
  func viewDidLoad()
}

protocol VoiceRecordInteractorInput: AnyObject {}

protocol VoiceRecordInteractorOutput: AnyObject {}

protocol VoiceRecordWireframe: AnyObject {}
