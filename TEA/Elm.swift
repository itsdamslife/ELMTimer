import UIKit

enum ElmView<Action> {
    case timerLabel(String, onChange: ((String) -> Action)?)
    case startButton(title: String, onTap: Action?)
    case stopButton(title: String, onTap: Action?)
}

class DisposeBag {
    var disposables: [Any] = []
    func append(_ value: Any) {
        disposables.append(value)
    }
}

fileprivate final class TA: NSObject {
    let execute: () -> ()
    
    init(_ action: @escaping () -> ()) {
        self.execute = action
    }
    
    @objc func action(_ sender: Any) {
        self.execute()
    }
}

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
                if let b = view as? UIButton {
                    startButton = b
                } else {
                    startButton = UIButton(type: .roundedRect)
                    startButton.translatesAutoresizingMaskIntoConstraints = false
                    insertArrangedSubview(startButton, at: index)
                    removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                startButton.setTitle(title, for: .normal)
                
                startButton.removeTarget(nil, action: nil, for: .touchUpInside)
                if let a = action {
                    let ta = TA {
                        sendAction(a)
                    }
                    disposeBag.append(ta)
                    startButton.addTarget(ta, action: #selector(TA.action), for: .touchUpInside)
                }
            case let .stopButton(title: title, onTap: action):
                let stopButton: UIButton
                if let b = view as? UIButton {
                    stopButton = b
                } else {
                    stopButton = UIButton(type: .roundedRect)
                    stopButton.translatesAutoresizingMaskIntoConstraints = false
                    insertArrangedSubview(stopButton, at: index)
                    removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                stopButton.setTitle(title, for: .normal)
                
                stopButton.removeTarget(nil, action: nil, for: .touchUpInside)
                if let a = action {
                    let ta = TA {
                        sendAction(a)
                    }
                    disposeBag.append(ta)
                    stopButton.addTarget(ta, action: #selector(TA.action), for: .touchUpInside)
                }
            case let .timerLabel(title, onChange: onChange):
                let timerLabel: UILabel
                if let b = view as? UILabel {
                    timerLabel = b
                } else {
                    timerLabel = UILabel()
                    timerLabel.translatesAutoresizingMaskIntoConstraints = false
                    timerLabel.font = UIFont.systemFont(ofSize: 14)
                    insertArrangedSubview(timerLabel, at: index)
                    removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                if timerLabel.text != title {
                    timerLabel.text = title
                }
                if let o = onChange {
                    let ta = TA { [unowned timerLabel] in
                        sendAction(o(timerLabel.text ?? ""))
                    }
                    disposeBag.append(ta)
                }
                
            }
        }
    }
}

class Driver<State, Action> {
    var state: State {
        didSet {
            updateForChangedState()
        }
    }
    var disposeBag: DisposeBag
    let update: (inout State, Action) -> Command<Action>?
    let view: (State) -> [ElmView<Action>]
    let subscriptions: (State) -> [Subscription<Action>]
    let rootView: UIStackView
    let model: TimerModel
    var notifications: [NotificationSubscription<Action>] = []
    
    init(_ initial: State, update: @escaping (inout State, Action) -> Command<Action>?, view: @escaping (State) -> [ElmView<Action>], subscriptions: @escaping (State) -> [Subscription<Action>], rootView: UIStackView, model: TimerModel) {
        self.state = initial
        self.update = update
        self.view = view
        self.rootView = rootView
        self.disposeBag = DisposeBag()
        self.subscriptions = subscriptions
        self.model = model
        updateForChangedState()
    }
    
    func updateForChangedState() {
        let d = DisposeBag()
        rootView.updateSubviews(virtualViews: view(state), sendAction: { [unowned self] in
            self.receive($0)
            }, disposeBag: d)
        self.disposeBag = d
        self.updateSubscriptions()
    }
    
    func updateSubscriptions() {
        let all = subscriptions(state)
        if all.count != notifications.count {
            notifications = []
            for s in all {
                switch s {
                case let .notification(name: name, action):
                    notifications.append(NotificationSubscription(name, handle: action, send: { [unowned self] in
                        self.receive($0)
                    }))
                }
            }
        } else {
            for i in 0..<all.count {
                switch all[i] {
                case let .notification(name: name, action):
                    assert(notifications[i].name == name) // todo
                    notifications[i].action = action
                }
            }
        }
    }
    
    func receive(_ action: Action) {
        if let command = update(&state, action) {
            command.execute(model) { [unowned self] in self.receive($0) }
        }
    }
}

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

enum Subscription<Action> {
    case notification(name: Notification.Name, (Notification) -> Action)
}

final class NotificationSubscription<Action> {
    let name: (Notification.Name)
    var action: (Notification) -> Action
    let send: (Action) -> ()
    init(_ name: Notification.Name, handle: @escaping (Notification) -> Action, send: @escaping (Action) -> ()) {
        self.name = name
        self.action = handle
        self.send = send
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [unowned self] note in
            self.send(self.action(note))
        }
    }
}
