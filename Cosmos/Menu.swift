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

    var menuIsVisible = false
    var shouldRevert = false

    var instructionLabel : UILabel!
    var timer : C4Timer!

    var selectionAction : SelectionAction?
    var infoAction : InfoAction?

    var menuRings : MenuRings!
    var menuIcons : MenuIcons!
    var menuSelector : MenuSelector!
    var menuShadow : MenuShadow!
    
    //MARK: -
    override func setup() {
        canvas.backgroundColor = clear
        canvas.frame = C4Rect(0,0,80,80)

        menuRings = MenuRings()
        menuSelector = MenuSelector()
        menuIcons = MenuIcons()
        menuShadow = MenuShadow()
        menuShadow.canvas.center = canvas.bounds.center
        
        canvas.add(menuShadow.canvas)
        canvas.add(menuRings.canvas)
        canvas.add(menuSelector.canvas)
        canvas.add(menuIcons.canvas)
        
        createGesture()

        createInstructionLabel()

        timer = C4Timer(interval: 5.0, count: 1) {
            self.showInstruction()
        }
        timer?.start()
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

    func revealMenu() {
        timer?.stop()

        hideInstruction()

        menuIsVisible = false
        menuSelector.revealMenuSound.play()
        menuShadow.revealShadow?.animate()
        menuRings.thickRingOut?.animate()
        menuRings.thinRingsOut?.animate()
        menuIcons.signIconsOut?.animate()

        delay(0.33) {
            self.menuRings.revealHideDividingLines(1.0)
            self.menuIcons.revealSignIcons?.animate()
        }
        delay(0.66) {
            self.menuRings.revealDashedRings?.animate()
            self.menuSelector.revealInfoButton?.animate()
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

        menuSelector.hideMenuSound.play()
        menuRings.hideDashedRings?.animate()
        menuSelector.hideInfoButton?.animate()
        menuRings.revealHideDividingLines(0.0)

        delay(0.16) {
            self.menuIcons.hideSignIcons?.animate()
        }
        delay(0.57) {
            menuRings.thinRingsIn?.animate()
        }
        delay(0.66) {
            self.menuIcons.signIconsIn?.animate()
            self.menuRings.thickRingIn?.animate()
            self.menuShadow.hideShadow?.animate()
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
                self.menuSelector.updateMenuHighlight(location)
            case .Cancelled, .Ended, .Failed:
                if let sa = self.selectionAction where self.menuSelector.currentSelection >= 0 {
                    sa(selection: self.menuSelector.currentSelection)
                }
                self.menuSelector.menuLabel?.hidden = true
                self.menuSelector.currentSelection = -1
                self.canvas.interactionEnabled = false

                if self.menuSelector.menuHighlight?.hidden == false {
                    self.menuSelector.menuHighlight?.hidden = true
                }
                if self.menuIsVisible {
                    self.hideMenu()
                } else {
                    self.shouldRevert = true
                }
                if let ib = self.menuSelector.infoButton {
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

    
}