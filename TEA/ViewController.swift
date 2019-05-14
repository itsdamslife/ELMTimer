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

        // reset first
        self.reset()
        self.timerLabel.text = "00:00:00"

        // Ambiguity : Who is responsible for timer?
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] timer in
            
            self.incrCountDownTime()
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
    }
    
    func incrCountDownTime() {
        timerModel.seconds += 1
        if timerModel.seconds > 59 {
            timerModel.mins += 1
            timerModel.seconds = 0
        }
        if timerModel.mins > 59 {
            timerModel.hours += 1
            timerModel.mins = 0
        }
    }
    
    func reset() {
        timerModel.hours = 0
        timerModel.mins = 0
        timerModel.seconds = 0
    }
}

