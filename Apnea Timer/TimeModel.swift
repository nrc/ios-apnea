//
//  TimeModel.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 21/04/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import Foundation

class TimeModel {
    internal var state: TimeState = TimeState.FRESH
    internal var timer: Timer? = nil
    internal var seconds: Int = 0
    internal var label = ""
    internal var plan: Plan
    internal var view: TimeView
    
    init(plan: Plan, view: TimeView) {
        self.view = view
        self.plan = plan
        handleStateChange()
    }
    
    // TODO timer should keep running if user switches to another app
    func start() {
        if state != TimeState.FRESH {
            return
        }
        state = TimeState.RUNNING
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimeModel.tick)), userInfo: nil, repeats: true)
        self.view.onStart()
    }
    
    func stop() {
        if state != TimeState.RUNNING {
            return
        }
        state = TimeState.DONE
        timer!.invalidate()
        self.view.onStop()
    }
    
    @objc func tick() {
        if state != TimeState.RUNNING {
            return
        }
        seconds -= 1
        if seconds <= 0 {
            handleStateChange()
        }
        self.view.update()
    }
    
    func handleStateChange() {
        let next = plan.nextState()
        if let next = next {
            // TODO handle nil time
            seconds = next.time!
            label = next.label
        } else {
            label = "done"
            stop()
        }
    }
    
    func timeLabel() -> String {
        let minutes = self.seconds / 60
        let seconds = self.seconds % 60
        return String(format: "\(minutes):%02d", seconds)
    }
    
    func textLabel() -> String {
        return label
    }
}

enum TimeState {
    case FRESH
    case RUNNING
    case DONE
}
