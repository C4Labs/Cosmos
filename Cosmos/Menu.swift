//
//  Menu.swift
//  Cosmos
//
//  Created by travis on 2015-09-10.
//  Copyright © 2015 C4. All rights reserved.
//

import C4

class Menu : C4CanvasController {
    var thickRing = C4Circle()
    var thickRingFrames = [C4Rect]()

    var thinRings = [C4Circle]()
    var thinRingFrames = [C4Rect]()

    var dashedRings = [C4Circle]()

    var menuDividingLines = [C4Line]()
    
    var signProvider = AstrologicalSignProvider()
    var currentSelection = 0

    override func setup() {
        canvas.backgroundColor = C4Purple
        createMenuHighlight()
        
        createThickRing()
        createThinRings()
        createDashedRings()
        createMenuDividingLines()

        createThickRingAnimations()
        createThinRingsOutAnimations()
        createThinRingsInAnimations()
        
        createSignIcons()
        createSignIconAnimations()
        
        createGesture()
        animOut()
    }
    
   func animOut() {
        delay(1.0) {
            self.thickRingOut?.animate()
            self.thinRingsOut?.animate()
            self.signIconsOut?.animate()
        }

        delay(1.5) {
            self.revealHideDividingLines(1.0)
            self.revealSignIcons?.animate()
        }
    }

    func animIn() {
        delay(0.25) {
            self.revealHideDividingLines(0.0)
            self.hideSignIcons?.animate()
        }

        delay(1.0) {
            self.thickRingIn?.animate()
            self.thinRingsIn?.animate()
            self.signIconsIn?.animate()
        }

        delay(2.5) {
            self.animOut()
        }
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
    
    func createGesture() {
        canvas.addLongPressGestureRecognizer { (location, state) -> () in
            switch state {
            case .Changed:
                self.updateMenuHighlight(location)
            case .Cancelled, .Ended, .Failed:
                if self.menuHighlight?.hidden == false {
                    self.menuHighlight?.hidden = true
                }
            default:
                _ = ""
            }
        }
    }

    
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
            
            let index = Int(radToDeg(ϴ)) / 30
            if currentSelection != index {
                currentSelection = index
                let rotation = C4Transform.makeRotation(degToRad(Double(currentSelection) * 30.0), axis: C4Vector(x: 0,y: 0,z: -1))
                self.menuHighlight?.transform = rotation
            }
        } else {
            menuHighlight?.hidden = true
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
}