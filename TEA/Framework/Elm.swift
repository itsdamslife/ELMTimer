
/// Imported from objc.io and reused with modification as per this app's requirement

import UIKit

// -----------------------------------------------
// A simple Elm implementation for Swift
// -----------------------------------------------

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
    
    init(_ initial: State,
         update: @escaping (inout State, Action) -> Command<Action>?,
         view: @escaping (State) -> [ElmView<Action>],
         subscriptions: @escaping (State) -> [Subscription<Action>],
         rootView: UIStackView,
         model: TimerModel) {
        
        self.disposeBag = DisposeBag()
        
        self.state = initial
        self.update = update
        self.view = view
        self.rootView = rootView
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
            command.execute(model) { [unowned self] in
                self.receive($0)
            }
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

final class TargetAction: NSObject {
    let execute: () -> ()
    
    init(_ action: @escaping () -> ()) {
        self.execute = action
    }
    
    @objc func action(_ sender: Any) {
        self.execute()
    }
}

// Autorelease
class DisposeBag {
    var disposables: [Any] = []
    func append(_ value: Any) {
        disposables.append(value)
    }
}

