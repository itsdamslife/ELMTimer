//
//  TimerModel.swift
//  TEA
//
//  Created by Damodar Shenoy on 14/05/19.
//  Copyright © 2019 It's Dams Life. All rights reserved.
//

import Foundation

// -----------------------------------
// Treat this like an external entity
// based on which value of our model
// will be calculated.
//
// For example: Web socket
// - Once a connection is opened
// - you can transfer data
// - and stop only when you disconnect
// -----------------------------------
class TimerModel {
    static let timerValueDidChange = Notification.Name("timerValueDidChange")
    static let textKey = "timer"
    
    private var hours: Int = 0
    private var mins: Int = 0
    private var seconds: Int = 0

    private var timer: Timer?
    
    var value: String {
        didSet {
            print("Timer now at : \(self.value)")
            NotificationCenter.default.post(name: TimerModel.timerValueDidChange, object: self, userInfo: [TimerModel.textKey: value])
        }
    }
    
    init() {
        self.value = "00:00:00"
    }
    
    
    private func incrCountDownTime() {
        seconds += 1
        if seconds > 59 {
            mins += 1
            seconds = 0
        }
        if mins > 59 {
            hours += 1
            mins = 0
        }
        updateValue()
    }
    
    private func reset() {
        hours = 0
        mins = 0
        seconds = 0
        updateValue()
    }
    
    private func updateValue() {
        var displayStr = (hours < 10) ? "0\(hours)" : "\(hours)"
        displayStr += (mins < 10) ? ":0\(mins)" : ":\(mins)"
        displayStr += (seconds < 10) ? ":0\(seconds)" : ":\(seconds)"
        value = displayStr
    }
    
    func startTimer() {
        guard self.timer == nil else {
            return
        }
        
        // reset first
        reset()

        print("Timer start")
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] timer in
            print("Timer running")
            self.incrCountDownTime()
        })
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
        print("Timer stopped")
    }
}
