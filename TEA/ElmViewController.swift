//
//  ElmViewController.swift
//  TEA
//
//  Created by Damodar Shenoy on 15/05/19.
//  Copyright © 2019 It's Dams Life. All rights reserved.
//

import UIKit

struct TEAState {
    var text: String
    
    enum Action {
        case start
        case stop
        case setText(String)
        case modelNotification(Notification)
    }
    
    mutating func update(_ action: Action) -> Command<Action>? {
        switch action {
        case .start:
            return .startTimer
        case .stop:
            return .stopTimer
        case .setText(let text):
            self.text = text
            return nil
        case .modelNotification(let note):
            text = note.userInfo?[TimerModel.textKey] as? String ?? "00:00:00"
            return nil
        }
    }
    
    var view: [ElmView<Action>] {
        return [
            ElmView.timerLabel("00:00:00", onChange: nil),
            ElmView.startButton(title: "Start", onTap: Action.start),
            ElmView.stopButton(title: "Stop", onTap: Action.stop)
        ]
    }
    
    var subscriptions: [Subscription<Action>] {
        return [
            .notification(name: TimerModel.timerValueDidChange, Action.modelNotification)
        ]
    }
}

class ElmViewController: UIViewController {

    @IBOutlet var rootView: UIStackView!
    
    let model = TimerModel()
    
    var driver: Driver<TEAState, TEAState.Action>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        driver = Driver.init(TEAState(text: model.value), update: { state, action in
            state.update(action)
        }, view: { $0.view }, subscriptions: { $0.subscriptions }, rootView: rootView, model: model)
    }
}
