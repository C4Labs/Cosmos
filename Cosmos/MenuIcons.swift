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

public class MenuIcons : C4CanvasController {
    public override func setup() {
        canvas.frame = C4Rect(0,0,80,80)
        canvas.backgroundColor = clear
        createSignIcons()
        createSignIconAnimations()
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
        let provider = AstrologicalSignProvider.sharedInstance
        //inner radius for the dots in the closed state menu
        let r = 10.5
        let dx = canvas.center.x
        let dy = canvas.center.y
        //loop through each sign in order
        for i in 0..<provider.order.count {
            //calculate the angle to the current sign
            let ϴ = M_PI/6 * Double(i)
            //grab the name of the current sign
            let name = provider.order[i]
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
        
        for i in 0..<provider.order.count {
            //outer radius for the signs
            let r = 129.0
            //calculate the angle for the current sign
            let ϴ = M_PI/6 * Double(i) + M_PI/12.0
            //append the target point to the outer array
            outerTargets.append(C4Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy))
        }
    }
    
    func taurus() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.taurus().shape
        shape.anchorPoint = C4Point()
        return shape
    }
    
    func aries() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.aries().shape
        shape.anchorPoint = C4Point(0.0777,0.536)
        return shape
    }
    
    func gemini() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.gemini().shape
        shape.anchorPoint = C4Point(0.996,0.0)
        return shape
    }
    
    func cancer() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.cancer().shape
        shape.anchorPoint = C4Point(0.0,0.275)
        return shape
    }
    
    func leo() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.leo().shape
        shape.anchorPoint = C4Point(0.379,0.636)
        return shape
    }
    
    func virgo() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.virgo().shape
        shape.anchorPoint = C4Point(0.750,0.387)
        return shape
    }
    
    func libra() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.libra().shape
        shape.anchorPoint = C4Point(1.00,0.559)
        return shape
    }
    
    func pisces() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.pisces().shape
        shape.anchorPoint = C4Point(0.099,0.004)
        return shape
    }
    
    func aquarius() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.aquarius().shape
        shape.anchorPoint = C4Point(0.0,0.263)
        return shape
    }
    
    func sagittarius() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.sagittarius().shape
        shape.anchorPoint = C4Point(1.0,0.349)
        return shape
    }
    
    func capricorn() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.capricorn().shape
        shape.anchorPoint = C4Point(0.288,0.663)
        return shape
    }
    
    func scorpio() -> C4Shape {
        let shape = AstrologicalSignProvider.sharedInstance.scorpio().shape
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
            for i in 0..<AstrologicalSignProvider.sharedInstance.order.count {
                let name = AstrologicalSignProvider.sharedInstance.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.outerTargets[i]
                }
            }
        }
        signIconsOut?.curve = .EaseOut
        
        signIconsIn = C4ViewAnimation(duration: 0.33) {
            for i in 0..<AstrologicalSignProvider.sharedInstance.order.count {
                let name = AstrologicalSignProvider.sharedInstance.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.innerTargets[i]
                }
            }
        }
        signIconsIn?.curve = .EaseOut
    }
}
