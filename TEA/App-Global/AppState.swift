//
//  AppState.swift
//  TEA
//
//  Created by Damodar Shenoy on 19/05/19.
//  Copyright © 2019 It's Dams Life. All rights reserved.
//

import Foundation

//----------------------------------------
// Structure which holds state of the App
// - Model value
// - Actions
// - Views
// - An update function
//----------------------------------------
struct AppState {
    
    // Our Model (value) to be displayed on screen
    var text: String
    
    // Command or Messgae
    enum Action {
        case start
        case stop
        case modelNotification(Notification)
    }
    
    // Update function - triggers updating of model
    mutating func update(_ action: Action) -> Command<Action>? {
        switch action {
        case .start:
            return .startTimer
        case .stop:
            return .stopTimer
        case .modelNotification(let note):
            text = note.userInfo?[TimerModel.textKey] as? String ?? "00:00:00"
            return nil
        }
    }
    
    // The Views - are tied to action ( command / message )
    var view: [ElmView<Action>] {
        return [
            ElmView.timerLabel(text, onChange: nil),
            ElmView.startButton(title: "Start", onTap: Action.start),
            ElmView.stopButton(title: "Stop", onTap: Action.stop)
        ]
    }
    
    // Helper - to notify our model to set the new value
    var subscriptions: [Subscription<Action>] {
        return [
            .notification(name: TimerModel.timerValueDidChange, Action.modelNotification)
        ]
    }
}
