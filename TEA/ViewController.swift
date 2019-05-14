//
//  ViewController.swift
//  TEA
//
//  Created by Damodar Shenoy on 09/05/19.
//  Copyright © 2019 It's Dams Life. All rights reserved.
//

import UIKit

///============================
/// #Model
///============================
struct CountDownTimer {
    var hours: Int = 0
    var mins: Int = 0
    var seconds: Int = 0
    
    mutating func incrCountDownTime() {
        seconds += 1
        if seconds > 59 {
            mins += 1
            seconds = 0
        }
        if mins > 59 {
            hours += 1
            mins = 0
        }
    }
    
    mutating func reset() {
        hours = 0
        mins = 0
        seconds = 0
    }
    
    // Ambiguity : Display string formatting to be given from here or from VC?
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: CountDownTimer) {
        appendInterpolation("Time lapsed : \(value.mins) minutes and \(value.seconds) seconds.")
    }
}

/// ============================
///  View Controller
/// ============================
class ViewController: UIViewController {

    @IBOutlet var timerLabel: UILabel!
    private var timerModel: CountDownTimer!
    private var timer: Timer? // Ambiguity : Who is responsible for timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timerLabel.text = "00:00:00"
        self.timerModel = CountDownTimer()
    }

    @IBAction func start(_ sender: UIButton) {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        // Ambiguity : Who is responsible for timer?
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] timer in
            
            self.timerModel.incrCountDownTime()
//            print("The current time elapsed is : \(String(describing: self.timerModel))")
            
            // Update label
            
            // Ambiguity : Display string to be given from here or from Model?
            var displayStr = (self.timerModel.hours < 10) ? "0\(self.timerModel.hours)" : "\(self.timerModel.hours)"
            displayStr += (self.timerModel.mins < 10) ? ":0\(self.timerModel.mins)" : ":\(self.timerModel.mins)"
            displayStr += (self.timerModel.seconds < 10) ? ":0\(self.timerModel.seconds)" : ":\(self.timerModel.seconds)"
            self.timerLabel.text = displayStr
        })
    }
    
    @IBAction func stop(_ sender: UIButton) {
        self.timer?.invalidate()
        self.timerModel.reset()
        self.timerLabel.text = "00:00:00"
    }
}

