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


import UIKit

public class MenuSelector : C4CanvasController {
    //The current menu selection index
    var currentSelection = -1
    //The label that displays the current selection's name
    var menuLabel : C4TextShape!
    //The shape that underlays the radial menu selection
    var highlight : C4Shape?
    //The button that triggers the info panel
    var infoButton : C4View!
    //Animations
    var revealInfoButton : C4ViewAnimation!
    var hideInfoButton : C4ViewAnimation!

    //Sounds for the opening and closing of the menu
    //We keep these sounds here because they are triggered based
    //on the user's selection
    let tick = C4AudioPlayer("tick.mp3")!
    let hideMenuSound = C4AudioPlayer("menuClose.mp3")!
    let revealMenuSound = C4AudioPlayer("menuOpen.mp3")!

    public override func setup() {
        //create the frame, small like the other classes
        canvas.frame = C4Rect(0,0,80,80)
        canvas.backgroundColor = clear
        createHighlight()
        createLabel()
        createInfoButton()
        createInfoButtonAnimations()
        adjustVolumes()
    }
    
    
    //MARK: -
    //MARK: Highlight
    func update(location: C4Point) {
        //check the distance of of user's gesture location
        let dist = distance(location, rhs: self.canvas.bounds.center)
        //if it is within the bounds of the out menu area
        if dist > 102 && dist < 156 {
            highlight?.hidden = false
            //create three vectors (a & b are constant)
            let a = C4Vector(x:self.canvas.width / 2.0+1.0, y:self.canvas.height/2.0)
            let b = C4Vector(x:self.canvas.width / 2.0, y:self.canvas.height/2.0)
            let c = C4Vector(x:location.x, y:location.y)
            
            //calculate the angle between a & c where b is the center of the canvas
            var ϴ = c.angleTo(a, basedOn: b)
            if c.y < a.y {
                ϴ = 2*M_PI - ϴ
            }
            
            //reveal the menu
            menuLabel?.hidden = false
            
            //calculate the index of the menu 0 = pices (on the right-hand side of the menu)
            let index = Int(radToDeg(ϴ)) / 30
            
            //if the current selection is new
            if currentSelection != index {
                //stop playback immediately
                tick.stop()
                //play the tick
                tick.play()
                //disable animations (because we want the text shape to switch immediately)
                C4ShapeLayer.disableActions = true
                //set the label's text by grabbing the name of the current selection
                menuLabel?.text = AstrologicalSignProvider.sharedInstance.order[index].capitalizedString
                //center the label
                menuLabel?.center = canvas.bounds.center
                C4ShapeLayer.disableActions = false
                //update the current selection
                currentSelection = index
                //rotate the highlight
                let rotation = C4Transform.makeRotation(degToRad(Double(currentSelection) * 30.0), axis: C4Vector(x: 0,y: 0,z: -1))
                self.highlight?.transform = rotation
            }
        } else {
            //the user's touch isn't within the bounds of the menu
            self.highlight?.hidden = true
            self.menuLabel?.hidden = true
            //the user isn't selecting anything, so set it to -1
            self.currentSelection = -1
            //check the info button and hittest it
            if let l = infoButton  {
                if l.hitTest(location, from:canvas) {
                    //if the user's touch is on the info button
                    self.menuLabel?.hidden = false
                    C4ShapeLayer.disableActions = true
                    //update the label
                    self.menuLabel?.text = "Info"
                    self.menuLabel?.center = canvas.bounds.center
                    C4ShapeLayer.disableActions = false
                }
            }
        }
    }

    //MARK: -
    //MARK: Highlight
    func createHighlight() {
        //The main shape of the highlight is a wedge that starts at the center of the canvas
        //M_PI/6.0 is technically 1/12th of a full circle
        let highlight = C4Wedge(center: canvas.center, radius: 156, start: M_PI/6.0, end: 0.0, clockwise: false)
        highlight.fillColor = cosmosblue
        highlight.lineWidth = 0.0
        highlight.opacity = 0.8
        highlight.interactionEnabled = false
        //We want the shape to rotate around the center, so we set the anchor point properly
        highlight.anchorPoint = C4Point()
        highlight.center = canvas.center
        highlight.hidden = true
        
        //To cut out everything we don't want to see, we create a donut that covers the area of the menu
        let donut = C4Circle(center: highlight.center, radius: 156-54/2.0)
        donut.fillColor = clear
        donut.lineWidth = 54
        //and use the donut as a mask on the wedge
        highlight.mask = donut
        
        canvas.add(highlight)
    }

    //MARK: -
    //MARK: Menu Label
    func createLabel() {
        let f = C4Font(name: "Menlo-Regular", size: 13)!
        let menuLabel = C4TextShape(text: "Cosmos", font: f)!
        menuLabel.center = canvas.center
        menuLabel.fillColor = white
        menuLabel.interactionEnabled = false
        canvas.add(menuLabel)
        menuLabel.hidden = true
    }

    //MARK: -
    //MARK: Audio
    func adjustVolumes() {
        hideMenuSound.volume = 0.66
        revealMenuSound.volume = 0.66
        tick.volume = 0.4
    }
    
    //MARK: -
    //MARK: Info Button
    func createInfoButton() {
        //The info button is a view because we want its frame to be larger than the small icon we'll use
        //This is so that area is easier to select for the user
        let infoButton = C4View(frame: C4Rect(0,0,44,44))
        let buttonImage = C4Image("info")!
        buttonImage.interactionEnabled = false
        buttonImage.center = infoButton.center
        infoButton.add(buttonImage)
        infoButton.opacity = 0.0
        infoButton.center = C4Point(canvas.center.x, canvas.center.y+190.0)
        canvas.add(infoButton)
    }
    
    //MARK: -
    //MARK: Animations
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
