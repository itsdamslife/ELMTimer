//
//  ElmViewController.swift
//  TEA
//
//  Created by Damodar Shenoy on 15/05/19.
//  Copyright © 2019 It's Dams Life. All rights reserved.
//

import UIKit

// ---------------------------------
// The View Controller
// ---------------------------------
class ElmViewController: UIViewController {

    var driver: Driver<AppState, AppState.Action>? // ELM - Runtime
    
    @IBOutlet var rootView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        driver = Driver.init(appState,
                             update: { state, action in state.update(action) },
                             view: { $0.view },
                             subscriptions: { $0.subscriptions },
                             rootView: rootView,
                             model: model)
    }
}
