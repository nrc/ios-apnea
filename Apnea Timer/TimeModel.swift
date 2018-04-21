//
//  TimeModel.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 21/04/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import Foundation

class TimeModel {
    internal var state: TimeState
    internal var timer: Timer?
    internal var seconds: Int
    internal var plan: Plan
    internal var view: TimeView
    
    init(plan: Plan, view: TimeView) {
        state = TimeState.FRESH
        timer = nil
        self.seconds = plan.nextState()!.time
        self.view = view
        self.plan = plan
    }
    
    func start() {
        if state != TimeState.FRESH {
            return
        }
        state = TimeState.RUNNING
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimeModel.tick)), userInfo: nil, repeats: true)
    }
    
    func stop() {
        if state != TimeState.RUNNING {
            return
        }
        state = TimeState.DONE
        timer!.invalidate()
    }
    
    @objc func tick() {
        if state != TimeState.RUNNING {
            return
        }
        seconds -= 1
        if seconds <= 0 {
            let next = plan.nextState()
            if let next = next {
                seconds = next.time
                // TODO use label
            } else {
                stop()
            }
        }
        self.view.update()
    }
    
    func label() -> String {
        let minutes = self.seconds / 60
        let seconds = self.seconds % 60
        // TODO seconds should always be two digits
        return "\(minutes):\(seconds)"
    }
}

enum TimeState {
    case FRESH
    case RUNNING
    case DONE
}
