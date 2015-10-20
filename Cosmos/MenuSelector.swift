// Copyright © 2015 C4
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import C4
import UIKit

public class MenuSelector : C4CanvasController {
    var currentSelection = -1
    var menuLabel : C4TextShape!
    var highlight : C4Shape?

    var infoButton : C4View!

    let tick = C4AudioPlayer("tick.mp3")!
    let hideMenuSound = C4AudioPlayer("menuClose.mp3")!
    let revealMenuSound = C4AudioPlayer("menuOpen.mp3")!

    public override func setup() {
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
    func update(location: C4Point) {
        let dist = distance(location, rhs: self.canvas.bounds.center)
        if dist > 102 && dist < 156 {
            highlight?.hidden = false
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
                menuLabel?.text = AstrologicalSignProvider.sharedInstance.order[index].capitalizedString
                menuLabel?.center = canvas.bounds.center
                C4ShapeLayer.disableActions = false
                currentSelection = index
                let rotation = C4Transform.makeRotation(degToRad(Double(currentSelection) * 30.0), axis: C4Vector(x: 0,y: 0,z: -1))
                self.highlight?.transform = rotation
            }
        } else {
            self.highlight?.hidden = true
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
        
        highlight = wedge
        canvas.add(highlight)
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
