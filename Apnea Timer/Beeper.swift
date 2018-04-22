//
//  Beeper.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 22/04/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import Foundation
import AVFoundation

protocol Beeper {
    func beep()
}

class BeepVibrate: Beeper {
    func beep() {
        let systemSoundID: SystemSoundID = 1052
        AudioServicesPlaySystemSound(systemSoundID)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
