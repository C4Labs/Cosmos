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

    override func setup() {
        self.createThickRing()
        self.createThinRings()
        self.createDashedRings()
        self.createMenuDividingLines()

        self.createThickRingAnimations()
        self.createThinRingsOutAnimations()
        self.createThinRingsInAnimations()

        animOut()
    }

    func animOut() {
        delay(1.0) {
            self.thickRingOut?.animate()
            self.thinRingsOut?.animate()
        }
        delay(2.0) {
            self.animIn()
        }
    }

    func animIn() {
        delay(1.0) {
            self.thickRingIn?.animate()
            self.thinRingsIn?.animate()
        }
        delay(2.0) {
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
            let line = C4Line([C4Point(),C4Point(54,0)])
            line.layer?.anchorPoint = CGPointMake(-1.88888,0)
            line.center = self.canvas.center
            let angle = M_PI / 6.0 * Double(i)
            let rot = C4Transform.makeRotation(angle)
            line.transform = rot
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

}