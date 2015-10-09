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

public class InfoPanel : C4CanvasController {
    var logo : C4Image?
    var text : UILabel?
    var link : C4TextShape?

    public override func setup() {
        canvas.backgroundColor = C4Color(red: 0, green: 0, blue: 0, alpha: 0.33)
        canvas.border.width = 4.0
        canvas.border.color = C4Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
        canvas.opacity = 0.0
        createLogo() 
        createLabel()
        createLink()
        linkGesture()
        hideGesture()
    }

    func createLogo() {
        let img = C4Image("logo")
        img.center = C4Point(canvas.center.x,canvas.height/6.0)
        logo = img
        canvas.add(logo)
    }

    func createLabel() {
        let message = "COSMOS is a lovingly\nbuilt app created\nby the C4 team.\n\n\nWe hope you enjoy\ncruising the COSMOS.\n\n\nYou can learn how\nto build this app\n on our site at:"

        let label = UILabel()
        label.font = UIFont(name: "Menlo-Regular", size: 18)
        label.numberOfLines = 40
        label.text = message
        label.textColor = .whiteColor()
        label.textAlignment = .Center
        label.sizeToFit()
        label.center = CGPoint(canvas.center)

        text = label
        canvas.add(text)
    }

    func createLink() {
        let text = C4TextShape(text:"www.c4ios.com", font: C4Font(name: "Menlo-Regular", size: 24))
        text.fillColor = white
        text.center = C4Point(canvas.center.x,canvas.height * 5.0/6.0)

        let a = C4Point(text.origin.x,text.frame.max.y+8)
        let b = C4Point(a.x + text.width + 1, a.y)

        let line = C4Line((a,b))
        line.lineWidth = 2.0
        line.strokeColor = C4Pink

        link = text
        canvas.add(link)
        canvas.add(line)
    }

    func linkGesture() {
        let press = link?.addLongPressGestureRecognizer { location, state in
            switch state {
            case .Began, .Changed:
                self.link?.fillColor = C4Pink
            case .Ended:
                if let l = self.link where l.hitTest(location) {
                    UIApplication.sharedApplication().openURL(NSURL(string:"http://www.c4ios.com")!)
                }
                fallthrough
            default:
                self.link?.fillColor = white
            }
        }
        press?.minimumPressDuration = 0.0
    }

    func hideGesture() {
        canvas.addTapGestureRecognizer { location, state in
            self.hide()
        }
    }

    func hide() {
        C4ViewAnimation(duration: 0.25) { () -> Void in
            self.canvas.opacity = 0.0
        }.animate()
    }

    func show() {
        C4ViewAnimation(duration: 0.25) { () -> Void in
            self.canvas.opacity = 1.0
        }.animate()
    }
}