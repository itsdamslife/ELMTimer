//
//  Views.swift
//  TEA
//
//  Created by Damodar Shenoy on 19/05/19.
//  Copyright © 2019 It's Dams Life. All rights reserved.
//

import UIKit

// ----------------------------------
// App specific Views declared
// ----------------------------------
enum ElmView<Action> {
    case timerLabel(String, onChange: ((String) -> Action)?)
    case startButton(title: String, onTap: Action?)
    case stopButton(title: String, onTap: Action?)
}

// ---------------------------------
// App specific commands declared
// ---------------------------------
enum Command<Action> {
    case startTimer
    case stopTimer
    
    func execute(_ model: TimerModel, _ handle: @escaping (Action) -> ()) {
        switch self {
        case .startTimer:
            model.startTimer()
        case .stopTimer:
            model.stopTimer()
        }
    }
}

// --------------------------------
// Laying out the UI for the app
// --------------------------------
extension UIStackView {
    func updateSubviews<Action>(virtualViews: [ElmView<Action>], sendAction: @escaping (Action) -> (), disposeBag: DisposeBag) {
        let diff = subviews.count - virtualViews.count
        if diff > 0 { // too many subviews
            for s in subviews.suffix(diff) {
                removeArrangedSubview(s)
                s.removeFromSuperview()
            }
        } else if diff < 0 {
            for _ in 0..<(-diff) {
                insertArrangedSubview(UIView(), at: subviews.count)
            }
        }
        assert(arrangedSubviews.count == virtualViews.count, "\((subviews.count, virtualViews.count))")
        for index in 0..<arrangedSubviews.endIndex {
            let view = arrangedSubviews[index]
            let virtualView = virtualViews[index]
            switch virtualView {
            case let .startButton(title: title, onTap: action):
                let startButton: UIButton
                if let b = view as? UIButton { // TODO: Check if its stack view and first one is button
                    startButton = b
                } else {
                    startButton = UIButton(type: .system)
                    startButton.backgroundColor = UIColor(named: "buttonColor")
                    startButton.setTitle("Start", for: .normal)
                    startButton.setTitleColor(UIColor(named: "systemGreen"), for: .normal)
                    startButton.titleLabel?.font = UIFont.systemFont(ofSize: 35)
                    startButton.layer.cornerRadius = 5.0
                    startButton.translatesAutoresizingMaskIntoConstraints = false
                    startButton.heightAnchor.constraint(equalToConstant: self.bounds.height/4 - 5).isActive = true
                    startButton.widthAnchor.constraint(equalToConstant: self.bounds.width).isActive = true
                    
                    insertArrangedSubview(startButton, at: index)
                    removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                startButton.setTitle(title, for: .normal)
                
                startButton.removeTarget(nil, action: nil, for: .touchUpInside)
                if let a = action {
                    let ta = TargetAction {
                        sendAction(a)
                    }
                    disposeBag.append(ta)
                    startButton.addTarget(ta, action: #selector(TargetAction.action), for: .touchUpInside)
                }
            case let .stopButton(title: title, onTap: action):
                let stopButton: UIButton
                if let sv = view as? UIStackView,
                    let b = sv.subviews[1] as? UIButton { // TODO: Check if its stack view and first one is button
                    stopButton = b
                } else {
                    
                    stopButton = UIButton(type: .system)
                    stopButton.backgroundColor = UIColor(named: "buttonColor")
                    stopButton.setTitle("Stop", for: .normal)
                    stopButton.setTitleColor(UIColor(named: "systemRed"), for: .normal)
                    stopButton.titleLabel?.font = UIFont.systemFont(ofSize: 35)
                    stopButton.layer.cornerRadius = 5.0
                    stopButton.translatesAutoresizingMaskIntoConstraints = false
                    stopButton.heightAnchor.constraint(equalToConstant: self.bounds.height/4 - 5).isActive = true
                    stopButton.widthAnchor.constraint(equalToConstant: self.bounds.width).isActive = true
                    
                    insertArrangedSubview(stopButton, at: index)
                    removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                stopButton.setTitle(title, for: .normal)
                
                stopButton.removeTarget(nil, action: nil, for: .touchUpInside)
                if let a = action {
                    let ta = TargetAction {
                        sendAction(a)
                    }
                    disposeBag.append(ta)
                    stopButton.addTarget(ta, action: #selector(TargetAction.action), for: .touchUpInside)
                }
            case let .timerLabel(title, onChange: onChange):
                let timerLabel: UILabel
                if let b = view as? UILabel {
                    timerLabel = b
                } else {
                    timerLabel = UILabel()
                    timerLabel.textAlignment = .center
                    timerLabel.translatesAutoresizingMaskIntoConstraints = false
                    timerLabel.font = UIFont.systemFont(ofSize: 75)
                    insertArrangedSubview(timerLabel, at: 0)
                    removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                if timerLabel.text != title {
                    timerLabel.text = title
                }
                if let o = onChange {
                    let ta = TargetAction { [unowned timerLabel] in
                        sendAction(o(timerLabel.text ?? ""))
                    }
                    disposeBag.append(ta)
                }
                
            }
        }
    }
}
