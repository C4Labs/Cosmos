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

typealias SelectionAction = (selection: Int) -> Void
typealias InfoAction = () -> Void

class Menu : C4CanvasController {
    //MARK: -
    //MARK: Properties
    var thickRing = C4Circle()
    var thickRingFrames = [C4Rect]()

    var thinRings = [C4Circle]()
    var thinRingFrames = [C4Rect]()

    var dashedRings = [C4Circle]()

    var menuDividingLines = [C4Line]()
    
    var signProvider = AstrologicalSignProvider()
    var currentSelection = -1

    var menuIsVisible = false

    var shouldRevert = false

    var menuLabel : C4TextShape?
    var shadow : C4Shape?

    var infoButton : C4View?

    var instructionLabel : UILabel?
    var timer : C4Timer?

    let tick = C4AudioPlayer("tick.mp3")
    let hideMenuSound = C4AudioPlayer("menuClose.mp3")
    let revealMenuSound = C4AudioPlayer("menuOpen.mp3")

    var selectionAction : SelectionAction?
    var infoAction : InfoAction?

    //MARK: -
    override func setup() {
        adjustVolumes()

        canvas.backgroundColor = clear
        canvas.frame = C4Rect(0,0,80,80)
        
        createShadow()
        createShadowAnimations()

        createMenuHighlight()

        createRingsLines()
        createRingsLinesAnimations()

        createSignIcons()
        createSignIconAnimations()
        
        createGesture()

        createMenuLabel()

        createInfoButton()
        createInfoButtonAnimations()

        createInstructionLabel()

        timer = C4Timer(interval: 5.0, count: 1) {
            self.showInstruction()
        }
        timer?.start()
    }

    //MARK: -
    //MARK: Rings and Lines

    func createRingsLines() {
        createThickRing()
        createThinRings()
        createDashedRings()
        createMenuDividingLines()
    }

    func createRingsLinesAnimations() {
        createThickRingAnimations()
        createThinRingsOutAnimations()
        createThinRingsInAnimations()
        createDashedRingAnimations()
    }

    func createThickRing() {
        let inner = C4Circle(center: canvas.center, radius: 14)
        let outer = C4Circle(center: canvas.center, radius: 225)
        thickRingFrames = [inner.frame,outer.frame]

        thickRing = inner
        self.thickRing.fillColor = clear
        self.thickRing.lineWidth = 3
        self.thickRing.strokeColor = cosmosblue
        self.thickRing.interactionEnabled = false

        canvas.add(thickRing)
    }

    var thickRingOut : C4ViewAnimation?
    var thickRingIn : C4ViewAnimation?

    func createThickRingAnimations() {
        thickRingOut = C4ViewAnimation(duration: 0.5) {
            self.thickRing.frame = self.thickRingFrames[1]
            self.thickRing.updatePath()
        }
        thickRingOut?.curve = .EaseOut

        thickRingIn = C4ViewAnimation(duration: 0.5) {
            self.thickRing.frame = self.thickRingFrames[0]
            self.thickRing.updatePath()
        }
        thickRingIn?.curve = .EaseOut
    }

    func createThinRings() {
        thinRings.append(C4Circle(center: canvas.center, radius: 8))
        thinRings.append(C4Circle(center: canvas.center, radius: 56))
        thinRings.append(C4Circle(center: canvas.center, radius: 78))
        thinRings.append(C4Circle(center: canvas.center, radius: 98))
        thinRings.append(C4Circle(center: canvas.center, radius: 102))
        thinRings.append(C4Circle(center: canvas.center, radius: 156))

        for i in 0..<self.thinRings.count {
            let ring = self.thinRings[i]
            ring.fillColor = clear
            ring.lineWidth = 1
            ring.strokeColor = cosmosblue
            ring.interactionEnabled = false
            if i > 0 {
                ring.opacity = 0.0
            }
            self.thinRingFrames.append(ring.frame)
        }

        for ring in thinRings {
            canvas.add(ring)
        }
    }

    var thinRingsOut : C4ViewAnimationSequence?

    func createThinRingsOutAnimations() {
        var animationArray = [C4ViewAnimation]()
        for i in 0..<self.thinRings.count-1 {
            let anim = C4ViewAnimation(duration: 0.075 + Double(i) * 0.01) {
                let circle = self.thinRings[i]

                if (i > 0) {
                    C4ViewAnimation(duration: 0.0375) {
                        circle.opacity = 1.0
                        }.animate()
                }

                circle.frame = self.thinRingFrames[i+1]
                circle.updatePath()
            }
            anim.curve = .EaseOut
            animationArray.append(anim)
        }
        thinRingsOut = C4ViewAnimationSequence(animations: animationArray)
    }

    var thinRingsIn : C4ViewAnimationSequence?

    func createThinRingsInAnimations() {
        var animationArray = [C4ViewAnimation]()
        for i in 1...self.thinRings.count {
            let anim = C4ViewAnimation(duration: 0.075 + Double(i) * 0.01, animations: { () -> Void in
                let circle = self.thinRings[self.thinRings.count - i]
                if self.thinRings.count - i > 0 {
                    C4ViewAnimation(duration: 0.0375) {
                        circle.opacity = 0.0
                        }.animate()
                }
                circle.frame = self.thinRingFrames[self.thinRings.count - i]
                circle.updatePath()
            })
            anim.curve = .EaseOut
            animationArray.append(anim)
        }
        thinRingsIn = C4ViewAnimationSequence(animations: animationArray)
    }

    func createDashedRings() {
        createShortDashedRing()
        createLongDashedRing()

        for ring in self.dashedRings {
            ring.strokeColor = cosmosblue
            ring.fillColor = clear
            ring.interactionEnabled = false
            ring.lineCap = .Butt
            self.canvas.add(ring)
        }
    }

    func createShortDashedRing() {
        let shortDashedRing = C4Circle(center: canvas.center, radius: 82+2)
        let pattern = [1.465,1.465,1.465,1.465,1.465,1.465,1.465,1.465*3.0] as [NSNumber]
        shortDashedRing.lineDashPattern = pattern
        shortDashedRing.strokeEnd = 0.995

        let angle = degToRad(-1.5)
        let rotation = C4Transform.makeRotation(angle)
        shortDashedRing.transform = rotation

        shortDashedRing.lineWidth = 0.0
        dashedRings.append(shortDashedRing)
    }

    func createLongDashedRing() {
        let longDashedRing = C4Circle(center: canvas.center, radius: 82+2)

        longDashedRing.lineWidth = 0.0

        let pattern = [1.465,1.465*9.0] as [NSNumber]
        longDashedRing.lineDashPattern = pattern
        longDashedRing.strokeEnd = 0.995

        let angle = degToRad(0.5)
        let rotation = C4Transform.makeRotation(angle)
        longDashedRing.transform = rotation

        let mask = C4Circle(center: C4Point(longDashedRing.width/2.0,longDashedRing.height/2.0), radius: 82+4)
        mask.fillColor = clear
        mask.lineWidth = 8
        longDashedRing.layer?.mask = mask.layer

        dashedRings.append(longDashedRing)
    }

    var revealDashedRings : C4ViewAnimation?
    var hideDashedRings : C4ViewAnimation?

    func createDashedRingAnimations() {
        revealDashedRings = C4ViewAnimation(duration: 0.25) {
            self.dashedRings[0].lineWidth = 4
            self.dashedRings[1].lineWidth = 12
        }
        revealDashedRings?.curve = .EaseOut

        hideDashedRings = C4ViewAnimation(duration: 0.25) {
            self.dashedRings[0].lineWidth = 0
            self.dashedRings[1].lineWidth = 0
        }
        hideDashedRings?.curve = .EaseOut
    }

    func createMenuDividingLines() {
        for i in 0...11 {
            let line = C4Line((C4Point(),C4Point(54,0)))
            line.anchorPoint = C4Point(-1.88888,0)
            line.center = canvas.center
            line.transform = C4Transform.makeRotation(M_PI / 6.0 * Double(i) , axis: C4Vector(x: 0, y: 0, z: -1))
            line.lineCap = .Butt
            line.strokeColor = cosmosblue
            line.lineWidth = 1.0
            line.strokeEnd = 0.0
            canvas.add(line)
            menuDividingLines.append(line)
        }
    }

    func revealHideDividingLines(target: Double) {
        var indices = [0,1,2,3,4,5,6,7,8,9,10,11]

        for i in 0...11 {
            delay(0.05*Double(i)) {
                let randomIndex = random(below: indices.count)
                let index = indices[randomIndex]

                C4ViewAnimation(duration: 0.1) {
                    self.menuDividingLines[index].strokeEnd = target
                    }.animate()
                
                indices.removeAtIndex(randomIndex)
            }
        }
    }

    //MARK: -
    //MARK: Audio
    func adjustVolumes() {
        hideMenuSound.volume = 0.66
        revealMenuSound.volume = 0.66
        tick.volume = 0.4
    }

    //MARK: -
    //MARK: Instruction Label

    func createInstructionLabel() {
        let instruction = UILabel(frame: CGRect(x: 0,y: 0,width: 320, height: 44))
        instruction.text = "press and hold to open menu\nthen drag to choose a sign"
        instruction.font = UIFont(name: "Menlo-Regular", size: 13)
        instruction.textAlignment = .Center
        instruction.textColor = .whiteColor()
        instruction.userInteractionEnabled = false
        instruction.center = CGPointMake(view.center.x,view.center.y - 128)
        instruction.numberOfLines = 2
        instruction.alpha = 0.0
        instructionLabel = instruction
        canvas.add(instructionLabel)
    }

    func showInstruction() {
        C4ViewAnimation(duration: 2.5) {
            self.instructionLabel?.alpha = 1.0
        }.animate()
    }

    func hideInstruction() {
        C4ViewAnimation(duration: 0.25) {
            self.instructionLabel?.alpha = 0.0
        }.animate()
    }

    //MARK: -
    //MARK: Info Button

    func createInfoButton() {
        let buttonView = C4View(frame: C4Rect(0,0,44,44))

        let buttonImage = C4Image("info")
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

    //MARK: -
    //MARK: Shadow

    func createShadow() {
        shadow = C4Rectangle(frame: C4Rect(UIScreen.mainScreen().bounds))
        shadow?.fillColor = black
        shadow?.lineWidth = 0
        shadow?.opacity = 0.0
        shadow?.center = C4Point(canvas.width/2,canvas.height/2)
        canvas.add(shadow)
    }

    var revealShadow : C4ViewAnimation?
    var hideShadow : C4ViewAnimation?

    func createShadowAnimations() {
        revealShadow = C4ViewAnimation(duration:0.25) {
            self.shadow?.opacity = 0.44
        }
        revealShadow?.curve = .EaseOut

        hideShadow = C4ViewAnimation(duration:0.25) {
            self.shadow?.opacity = 0.0
        }
        hideShadow?.curve = .EaseOut
    }

    //MARK: -
    //MARK: Menu Label

    func createMenuLabel() {
        let ts = C4TextShape(text: "Cosmos", font: C4Font(name: "Menlo-Regular", size: 13))
        ts.center = canvas.center
        ts.fillColor = white
        ts.interactionEnabled = false
        menuLabel = ts
        canvas.add(menuLabel)
        menuLabel?.hidden = true
    }

    func revealMenu() {
        timer?.stop()

        hideInstruction()

        menuIsVisible = false
        revealMenuSound.play()
        revealShadow?.animate()
        thickRingOut?.animate()
        thinRingsOut?.animate()
        signIconsOut?.animate()

        delay(0.33) {
            self.revealHideDividingLines(1.0)
            self.revealSignIcons?.animate()
        }
        delay(0.66) {
            self.revealDashedRings?.animate()
            self.revealInfoButton?.animate()
        }
        delay(1.0) {
            self.menuIsVisible = true
            if self.shouldRevert {
                self.hideMenu()
                self.shouldRevert = false
            }
        }
    }

    func hideMenu() {
        if instructionLabel?.alpha > 0.0 {
            hideInstruction()
        }

        menuIsVisible = false

        hideMenuSound.play()
        hideDashedRings?.animate()
        hideInfoButton?.animate()
        self.revealHideDividingLines(0.0)

        delay(0.16) {
            self.hideSignIcons?.animate()
        }
        delay(0.57) {
            self.thinRingsIn?.animate()
        }
        delay(0.66) {
            self.signIconsIn?.animate()
            self.thickRingIn?.animate()
            self.hideShadow?.animate()
            self.canvas.interactionEnabled = true
        }
    }

    //MARK: -
    //MARK: Gesture
    func createGesture() {
        canvas.addLongPressGestureRecognizer { (location, state) -> () in
            switch state {
            case .Began:
                self.revealMenu()
            case .Changed:
                self.updateMenuHighlight(location)
            case .Cancelled, .Ended, .Failed:
                if let sa = self.selectionAction where self.currentSelection >= 0 {
                    sa(selection: self.currentSelection)
                }
                self.menuLabel?.hidden = true
                self.currentSelection = -1
                self.canvas.interactionEnabled = false

                if self.menuHighlight?.hidden == false {
                    self.menuHighlight?.hidden = true
                }
                if self.menuIsVisible {
                    self.hideMenu()
                } else {
                    self.shouldRevert = true
                }
                if let ib = self.infoButton {
                    if ib.hitTest(location, from: self.canvas),
                        let ia = self.infoAction {
                            delay(0.75) {
                                ia()
                            }
                    }
                }
            default:
                _ = ""
            }
        }
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
    //MARK: Sign Icons
    var signIcons = [String:C4Shape]()
    
    func createSignIcons() {
        signIcons["aries"] = aries()
        signIcons["taurus"] = taurus()
        signIcons["gemini"] = gemini()
        signIcons["cancer"] = cancer()
        signIcons["leo"] = leo()
        signIcons["virgo"] = virgo()
        signIcons["libra"] = libra()
        signIcons["scorpio"] = scorpio()
        signIcons["sagittarius"] = sagittarius()
        signIcons["capricorn"] = capricorn()
        signIcons["aquarius"] = aquarius()
        signIcons["pisces"] = pisces()
        
        for shape in [C4Shape](self.signIcons.values) {
            shape.strokeEnd = 0.001
            shape.transform = C4Transform.makeScale(0.64, 0.64, 1.0)
            shape.lineCap = .Round
            shape.lineJoin = .Round
            shape.lineWidth = 2
            shape.strokeColor = white
            shape.fillColor = clear
        }
        
        positionSignIcons()
    }
    
    var innerTargets = [C4Point]()
    var outerTargets = [C4Point]()
    
    func positionSignIcons() {
        //inner radius for the dots in the closed state menu
        let r = 10.5
        let dx = canvas.center.x
        let dy = canvas.center.y
        //loop through each sign in order
        for i in 0..<signProvider.order.count {
            //calculate the angle to the current sign
            let ϴ = M_PI/6 * Double(i)
            //grab the name of the current sign
            let name = signProvider.order[i]
            //grab the shape from our local signIcons dictionary
            if let sign = signIcons[name] {
                //set the center point (remember we've already adjusted the anchorPoint)
                sign.center = C4Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy)
                //add the sign to the canvas
                canvas.add(sign)
                //reset the anchorPoint to the center of the sign's view
                sign.anchorPoint = C4Point(0.5,0.5)
                //set the actual center of the sign as the target for the closed state of the menu
                innerTargets.append(sign.center)
            }
        }
        
        for i in 0..<signProvider.order.count {
            //outer radius for the signs
            let r = 129.0
            //calculate the angle for the current sign
            let ϴ = M_PI/6 * Double(i) + M_PI/12.0
            //append the target point to the outer array
            outerTargets.append(C4Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy))
        }
    }
    
    func taurus() -> C4Shape {
        let shape = signProvider.taurus().shape
        shape.anchorPoint = C4Point()
        return shape
    }
    
    func aries() -> C4Shape {
        let shape = signProvider.aries().shape
        shape.anchorPoint = C4Point(0.0777,0.536)
        return shape
    }
    
    func gemini() -> C4Shape {
        let shape = signProvider.gemini().shape
        shape.anchorPoint = C4Point(0.996,0.0)
        return shape
    }
    
    func cancer() -> C4Shape {
        let shape = signProvider.cancer().shape
        shape.anchorPoint = C4Point(0.0,0.275)
        return shape
    }
    
    func leo() -> C4Shape {
        let shape = signProvider.leo().shape
        shape.anchorPoint = C4Point(0.379,0.636)
        return shape
    }
    
    func virgo() -> C4Shape {
        let shape = signProvider.virgo().shape
        shape.anchorPoint = C4Point(0.750,0.387)
        return shape
    }
    
    func libra() -> C4Shape {
        let shape = signProvider.libra().shape
        shape.anchorPoint = C4Point(1.00,0.559)
        return shape
    }
    
    func pisces() -> C4Shape {
        let shape = signProvider.pisces().shape
        shape.anchorPoint = C4Point(0.099,0.004)
        return shape
    }
    
    func aquarius() -> C4Shape {
        let shape = signProvider.aquarius().shape
        shape.anchorPoint = C4Point(0.0,0.263)
        return shape
    }
    
    func sagittarius() -> C4Shape {
        let shape = signProvider.sagittarius().shape
        shape.anchorPoint = C4Point(1.0,0.349)
        return shape
    }
    
    func capricorn() -> C4Shape {
        let shape = signProvider.capricorn().shape
        shape.anchorPoint = C4Point(0.288,0.663)
        return shape
    }
    
    func scorpio() -> C4Shape {
        let shape = signProvider.scorpio().shape
        shape.anchorPoint = C4Point(0.255,0.775)
        return shape
    }
    
    var signIconsOut : C4ViewAnimation?
    var signIconsIn : C4ViewAnimation?
    var revealSignIcons : C4ViewAnimation?
    var hideSignIcons : C4ViewAnimation?

    func createSignIconAnimations() {
        revealSignIcons = C4ViewAnimation(duration: 0.5) {
            for sign in [C4Shape](self.signIcons.values) {
                sign.strokeEnd = 1.0
            }
        }
        revealSignIcons?.curve = .EaseOut

        hideSignIcons = C4ViewAnimation(duration: 0.5) {
            for sign in [C4Shape](self.signIcons.values) {
                sign.strokeEnd = 0.001
            }
        }
        hideSignIcons?.curve = .EaseOut

        signIconsOut = C4ViewAnimation(duration: 0.33) {
            for i in 0..<self.signProvider.order.count {
                let name = self.signProvider.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.outerTargets[i]
                }
            }
        }
        signIconsOut?.curve = .EaseOut

        signIconsIn = C4ViewAnimation(duration: 0.33) {
            for i in 0..<self.signProvider.order.count {
                let name = self.signProvider.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.innerTargets[i]
                }
            }
        }
        signIconsIn?.curve = .EaseOut
    }
}