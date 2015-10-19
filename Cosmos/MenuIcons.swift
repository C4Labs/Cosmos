//
//  MenuIcons.swift
//  Cosmos
//
//  Created by travis on 2015-10-19.
//  Copyright © 2015 C4. All rights reserved.
//

import C4
import UIKit

public class MenuIcons : C4CanvasController {
    //MARK: -
    //MARK: Properties
    var signProvider : AstrologicalSignProvider!
    
    public override func setup() {
        signProvider = AstrologicalSignProvider()
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
