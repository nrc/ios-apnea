//
//  ViewController.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 1/01/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TimeView {
    //MARK: Properties
    @IBOutlet weak var timerLabel: UILabel!
    var model: TimeModel!
    
    //MARK: Actions
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        self.model.start()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = TimeModel.init(plan: defaultO2Plan(), view: self)
        self.timerLabel.text = model.label()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func update() {
        self.timerLabel.text = model.label()
    }
}

