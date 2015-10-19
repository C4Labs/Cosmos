//
//  MenuShadow.swift
//  Cosmos
//
//  Created by travis on 2015-10-19.
//  Copyright © 2015 C4. All rights reserved.
//

import C4
import UIKit

public class MenuShadow : C4CanvasController {
    var shadow : C4Shape!

    public override func setup() {
        canvas.frame = C4Rect(UIScreen.mainScreen().bounds)
        canvas.backgroundColor = black
        canvas.opacity = 0.0
        createShadowAnimations()
    }
    
    var revealShadow : C4ViewAnimation?
    var hideShadow : C4ViewAnimation?
    
    func createShadowAnimations() {
        revealShadow = C4ViewAnimation(duration:0.25) {
            self.canvas.opacity = 0.44
        }
        revealShadow?.curve = .EaseOut
        
        hideShadow = C4ViewAnimation(duration:0.25) {
            self.canvas.opacity = 0.0
        }
        hideShadow?.curve = .EaseOut
    }

}
