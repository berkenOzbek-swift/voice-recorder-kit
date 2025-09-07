//
//  VoiceRecordInteractor.swift
//  VoiceRecorderExampleApp
//
//  Created by berken on 6.09.2025.
//  
//

import Foundation

final class VoiceRecordInteractor {
  weak var output: VoiceRecordInteractorOutput?
}

extension VoiceRecordInteractor: VoiceRecordInteractorInput {}
