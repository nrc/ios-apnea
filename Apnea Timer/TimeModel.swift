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
        update_from_plan(plan: self.plan.nextState(elapsedSeconds: 0)!)
    }
    
    internal func start() {
        if state == TimeState.PAUSED || state == TimeState.FRESH {
            self.view.onStart()
            handleStateChange()
            self.view.update()
        }
    }
    
    func stop() {
        if state == TimeState.RUNNING || state == TimeState.PAUSED {
            if let _ = timer {
                stopTimer()
            }
            self.view.onStop()
            plan.onStop(elapsedSeconds: seconds)
            if let record = plan.getRecord() {
                DataManager.getDataManager().append(record: record)
            }
            state = TimeState.DONE
            label = "done"
            self.view.update()
        }
    }
    
    internal func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimeModel.tick)), userInfo: nil, repeats: true)
    }
    
    internal func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        self.timer = nil
    }

    @objc func tick() {
        assert(state != TimeState.FRESH)
        assert(state != TimeState.DONE)
        if state == TimeState.PAUSED {
            seconds += 1
        }
        if state == TimeState.RUNNING {
            seconds -= 1
        }

        if seconds == 0 {
            handleStateChange()
        }
        self.view.update()
    }
    
    internal func handleStateChange() {
        stopTimer()

        if state == TimeState.RUNNING {
            beeper.beep()
        }

        if state != TimeState.FRESH {
            let next = plan.nextState(elapsedSeconds: seconds)
            if let next = next {
                update_from_plan(plan: next)
            } else {
                stop()
                return
            }
        }

        if seconds == 0 {
            state = TimeState.PAUSED
        } else {
            state = TimeState.RUNNING
        }
        startTimer()
    }

    internal func update_from_plan(plan: PlanState) {
        if let time = plan.time {
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
        label = plan.label
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
    // Either paused or running but counting up
    case PAUSED
    case DONE
}
