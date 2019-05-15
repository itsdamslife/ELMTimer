//
//  TimerModel.swift
//  TEA
//
//  Created by Damodar Shenoy on 14/05/19.
//  Copyright © 2019 It's Dams Life. All rights reserved.
//

import Foundation

class TimerModel {
    static let timerValueDidChange = Notification.Name("timerValueDidChange")
    static let textKey = "timer"
    
    private var hours: Int = 0
    private var mins: Int = 0
    private var seconds: Int = 0

    private var timer: Timer?
    
    var value: String {
        didSet {
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
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        // reset first
        reset()
        value = "00:00:00"

        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] timer in
            self.incrCountDownTime()
        })
    }
    
    func stopTimer() {
        self.timer?.invalidate()
    }
}
