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
    //MARK: -
    //MARK: Properties
    var link : C4TextShape?

    //MARK: -
    //MARK: Setup
    public override func setup() {
        //makes the background slightly dark
        canvas.backgroundColor = C4Color(red: 0, green: 0, blue: 0, alpha: 0.33)
        //hides the info panel
        canvas.opacity = 0.0
        //creates the logo
        createLogo()
        //creates the label
        createLabel()
        //creates the link
        createLink()
        //creates a gesture to open the C4 site
        linkGesture()
        //creates a gesture to hide the panel
        hideGesture()
    }

    //MARK: -
    //MARK: Logo
    func createLogo() {
        //creates an image and positions it before adding it to the screen
        let logo = C4Image("logo")!
        logo.center = C4Point(canvas.center.x,canvas.height/6.0)
        canvas.add(logo)
    }

    //MARK: -
    //MARK: Label
    func createLabel() {
        //creates the message to be displayed in the label
        let message = "COSMOS is a lovingly\nbuilt app created\nby the C4 team.\n\n\nWe hope you enjoy\ncruising the COSMOS.\n\n\nYou can learn how\nto build this app\n on our site at:"

        //creates a label and styles / positions it before adding it to the screen
        //uses a UILabel because we want to have multiple lines of text
        let text = UILabel()
        text.font = UIFont(name: "Menlo-Regular", size: 18)
        text.numberOfLines = 40
        text.text = message
        text.textColor = .whiteColor()
        text.textAlignment = .Center
        text.sizeToFit()
        text.center = CGPoint(canvas.center)

        canvas.add(text)
    }

    //MARK: -
    //MARK: Link
    func createLink() {
        //creates a textshape
        let f = C4Font(name: "Menlo-Regular", size: 24)!
        let text = C4TextShape(text:"www.c4ios.com", font: f)!
        text.fillColor = white
        text.center = C4Point(canvas.center.x,canvas.height * 5.0/6.0)

        //creates the pink line under the text shape
        let a = C4Point(text.origin.x,text.frame.max.y+8)
        let b = C4Point(a.x + text.width + 1, a.y)

        let line = C4Line((a,b))
        line.lineWidth = 2.0
        line.strokeColor = C4Pink

        //associates the link variable with the text
        link = text
        
        //adds both elements to the screen
        canvas.add(link)
        canvas.add(line)
    }

    //MARK: -
    //MARK: Gesture
    func linkGesture() {
        //creates a press gesture
        let press = link?.addLongPressGestureRecognizer { location, state in
            switch state {
            case .Began, .Changed:
                //if the press starts, or the user is dragging, make sure the text color is pink
                self.link?.fillColor = C4Pink
            case .Ended:
                //if the user chooses to release the gesture, test to see if their location is over the link shape
                if let l = self.link where l.hitTest(location) {
                    //if so, open the link in safari
                    UIApplication.sharedApplication().openURL(NSURL(string:"http://www.c4ios.com/cosmos/")!)
                }
                fallthrough
            default:
                //set the text color back to white
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

    //MARK: -
    //MARK: Animations
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