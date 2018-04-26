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
    internal var beeper: Beeper
    
    init(plan: Plan, view: TimeView, beeper: Beeper) {
        self.view = view
        self.plan = plan
        self.beeper = beeper
        handleStateChange()
    }
    
    // TODO timer should keep running if user switches to another app
    func start() {
        if state == TimeState.FRESH || state == TimeState.PAUSED {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimeModel.tick)), userInfo: nil, repeats: true)
            if state == TimeState.FRESH {
                self.view.onStart()
            }
            state = TimeState.RUNNING
        }
    }
    
    func stop() {
        if state == TimeState.RUNNING {
            timer!.invalidate()
        }
        if state == TimeState.RUNNING || state == TimeState.PAUSED {
            self.view.onStop()
        }
        state = TimeState.DONE
    }
    
    func pause() {
        state = TimeState.PAUSED
        timer!.invalidate()
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
        if state == TimeState.RUNNING {
            beeper.beep()
        }

        let next = plan.nextState()
        if let next = next {
            if let time = next.time {
                seconds = time
            } else {
                pause()
            }
            label = next.label
        } else {
            label = "done"
            stop()
        }
    }
    
    func timeLabel() -> String {
        if state == TimeState.PAUSED {
            return "-:--"
        }

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
    case PAUSED
    case DONE
}
