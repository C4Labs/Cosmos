//
//  MenuHighlight.swift
//  Cosmos
//
//  Created by travis on 2015-10-19.
//  Copyright © 2015 C4. All rights reserved.
//

import C4
import UIKit

public class MenuSelector : C4CanvasController {
    var signProvider : AstrologicalSignProvider!
    var currentSelection = -1
    var menuLabel : C4TextShape!

    var infoButton : C4View!

    let tick = C4AudioPlayer("tick.mp3")!
    let hideMenuSound = C4AudioPlayer("menuClose.mp3")!
    let revealMenuSound = C4AudioPlayer("menuOpen.mp3")!

    public override func setup() {
        signProvider = AstrologicalSignProvider()
        canvas.frame = C4Rect(0,0,80,80)
        canvas.backgroundColor = clear
        createMenuHighlight()
        createMenuLabel()
        createInfoButton()
        createInfoButtonAnimations()
        adjustVolumes()
    }
    
    //MARK: -
    //MARK: Audio
    func adjustVolumes() {
        hideMenuSound.volume = 0.66
        revealMenuSound.volume = 0.66
        tick.volume = 0.4
    }
    
    //MARK: -
    //MARK: Menu Label
    
    func createMenuLabel() {
        let f = C4Font(name: "Menlo-Regular", size: 13)!
        let ts = C4TextShape(text: "Cosmos", font: f)!
        ts.center = canvas.center
        ts.fillColor = white
        ts.interactionEnabled = false
        menuLabel = ts
        canvas.add(menuLabel)
        menuLabel?.hidden = true
    }

    //MARK: -
    //MARK: Highlight
    func updateMenuHighlight(location: C4Point) {
        let dist = distance(location, rhs: self.canvas.bounds.center)
        if dist > 102 && dist < 156 {
            menuHighlight?.hidden = false
            let a = C4Vector(x:self.canvas.width / 2.0+1.0, y:self.canvas.height/2.0)
            let b = C4Vector(x:self.canvas.width / 2.0, y:self.canvas.height/2.0)
            let c = C4Vector(x:location.x, y:location.y)
            
            var ϴ = c.angleTo(a, basedOn: b)
            if c.y < a.y {
                ϴ = 2*M_PI - ϴ
            }
            
            menuLabel?.hidden = false
            
            let index = Int(radToDeg(ϴ)) / 30
            
            if currentSelection != index {
                tick.stop()
                tick.play()
                C4ShapeLayer.disableActions = true
                menuLabel?.text = signProvider.order[index].capitalizedString
                menuLabel?.center = canvas.bounds.center
                C4ShapeLayer.disableActions = false
                currentSelection = index
                let rotation = C4Transform.makeRotation(degToRad(Double(currentSelection) * 30.0), axis: C4Vector(x: 0,y: 0,z: -1))
                self.menuHighlight?.transform = rotation
            }
        } else {
            self.menuHighlight?.hidden = true
            self.menuLabel?.hidden = true
            self.currentSelection = -1
            if let l = infoButton  {
                if l.hitTest(location, from:canvas) {
                    self.menuLabel?.hidden = false
                    C4ShapeLayer.disableActions = true
                    self.menuLabel?.text = "Info"
                    self.menuLabel?.center = canvas.bounds.center
                    C4ShapeLayer.disableActions = false
                }
            }
        }
    }
    
    var menuHighlight : C4Shape?
    func createMenuHighlight() {
        let wedge = C4Wedge(center: canvas.center, radius: 156, start: M_PI/6.0, end: 0.0, clockwise: false)
        wedge.fillColor = cosmosblue
        wedge.lineWidth = 0.0
        wedge.opacity = 0.8
        wedge.interactionEnabled = false
        wedge.anchorPoint = C4Point()
        wedge.center = canvas.center
        wedge.hidden = true
        
        let donut = C4Circle(center: wedge.center, radius: 156-54/2.0)
        donut.fillColor = clear
        donut.lineWidth = 54
        wedge.mask = donut
        
        menuHighlight = wedge
        canvas.add(menuHighlight)
    }
    
    //MARK: -
    //MARK: Info Button
    
    func createInfoButton() {
        let buttonView = C4View(frame: C4Rect(0,0,44,44))
        
        let buttonImage = C4Image("info")!
        buttonImage.interactionEnabled = false
        buttonImage.center = buttonView.center
        buttonView.add(buttonImage)
        buttonView.opacity = 0.0
        buttonView.center = C4Point(canvas.center.x, canvas.center.y+190.0)
        infoButton = buttonView
        canvas.add(infoButton)
    }
    
    var revealInfoButton : C4ViewAnimation?
    var hideInfoButton : C4ViewAnimation?
    
    func createInfoButtonAnimations() {
        revealInfoButton = C4ViewAnimation(duration:0.33) {
            self.infoButton?.opacity = 1.0
        }
        revealInfoButton?.curve = .EaseOut
        
        hideInfoButton = C4ViewAnimation(duration:0.33) {
            self.infoButton?.opacity = 0.0
        }
        hideInfoButton?.curve = .EaseOut
    }
}
