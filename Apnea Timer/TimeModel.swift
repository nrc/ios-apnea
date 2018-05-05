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
    
    func start() {
        if state == TimeState.PAUSED {
            timer!.invalidate()
            handleStateChange()
            self.view.update()
      }
        if state == TimeState.FRESH {
            state = TimeState.RUNNING
            self.view.onStart()
            startTimer()
        }
    }
    
    // TODO if we stop, then we should tell the plan how many seconds in we stopped at
    func stop() {
        if state == TimeState.RUNNING || state == TimeState.PAUSED {
            timer!.invalidate()
            state = TimeState.DONE
            self.view.onStop()
            plan.onStop(seconds)
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimeModel.tick)), userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        assert(state != TimeState.FRESH)
        assert(state != TimeState.DONE)
        if state == TimeState.PAUSED {
            seconds += 1
        }
        if state == TimeState.RUNNING {
            seconds -= 1
            if seconds <= 0 {
                timer!.invalidate()
                handleStateChange()
            }
        }
        self.view.update()
    }
    
    // Pre-condition: timer should be invalid
    func handleStateChange() {
        if state == TimeState.RUNNING {
            beeper.beep()
        }

        let next = plan.nextState(elapsedSeconds: seconds)
        if let next = next {
            if let time = next.time {
                seconds = time
                if state != TimeState.FRESH {
                    state = TimeState.RUNNING
                }
            } else {
                seconds = 0
                if state != TimeState.FRESH {
                    state = TimeState.PAUSED
                }
            }
            if state != TimeState.FRESH {
                startTimer()
            }
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
    case PAUSED
    case DONE
}
