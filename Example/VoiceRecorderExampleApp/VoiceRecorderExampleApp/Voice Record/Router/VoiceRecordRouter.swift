//
//  VoiceRecordRouter.swift
//  VoiceRecorderExampleApp
//
//  Created by berken on 6.09.2025.
//  
//

import Foundation
import UIKit

final class VoiceRecordRouter {
  weak var view: UIViewController?
  
  static func setupModule() -> VoiceRecordViewController {
    let viewController = UIStoryboard.viewController(fromStoryboard: "VoiceRecord") as! VoiceRecordViewController
    let presenter = VoiceRecordPresenter()
    let router = VoiceRecordRouter()
    let interactor = VoiceRecordInteractor()
    
    viewController.presenter =  presenter
    
    presenter.view = viewController
    presenter.router = router
    presenter.interactor = interactor
    
    router.view = viewController
    
    interactor.output = presenter
    
    return viewController
  }
}

extension VoiceRecordRouter: VoiceRecordWireframe {}
