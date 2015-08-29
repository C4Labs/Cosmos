//
//  ViewController.swift
//  Cosmos
//
//  Created by travis on 2015-08-06.
//  Copyright © 2015 C4. All rights reserved.
//

import UIKit
import C4

let cosmosprpl = C4Color(red:0.565, green: 0.075, blue: 0.996, alpha: 1.0)
let cosmosblue = C4Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)
let cosmosbkgd = C4Color(red: 0.078, green: 0.118, blue: 0.306, alpha: 1.0)

class ViewController: C4CanvasController {
    var background = ParallaxBackground()
    
    override func setup() {
        canvas.add(background.canvas)
    }
}