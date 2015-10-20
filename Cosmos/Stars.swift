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
import C4

let gapBetweenSigns : CGFloat = 10.0

class Stars : C4CanvasController, UIScrollViewDelegate {
    //Specifies how quickly each layer moves, relative to top layer, order = [bottom, ..., top]
    var speeds : [CGFloat] = [0.08,0.0,0.10,0.12,0.15,1.0,0.8,1.0]
    //array of infinite scrollview layers
    lazy var scrollviews = [InfiniteScrollView]()
    //variable used for marking observeValueForKeyPath
    var scrollviewOffsetContext = 0

    var signLines : SignLines!
    var bigStars : StarsBig!
    var snapTargets : [CGFloat]!
    

    override func setup() {
        //changes background color (specified in main view controller)
        canvas.backgroundColor = cosmosbkgd

        //adds layers to parallax background
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "0Star", starCount: 20, speed: speeds[0]))
        scrollviews.append(createVignette())
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "2Star", starCount: 20, speed: speeds[2]))
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "3Star", starCount: 20, speed: speeds[3]))
        scrollviews.append(StarsBackground(frame: view.frame, imageName: "4Star", starCount: 20, speed: speeds[4]))
        
        signLines = SignLines(frame: view.frame)
        scrollviews.append(signLines)
        
        scrollviews.append(StarsSmall(frame: view.frame, speed: speeds[6]))

        bigStars = StarsBig(frame: view.frame)
        bigStars.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &scrollviewOffsetContext)
        bigStars.contentOffset = CGPointMake(view.frame.size.width * CGFloat(gapBetweenSigns / 2.0), 0)
        bigStars.delegate = self
        scrollviews.append(bigStars)
        
        //adds all layers to the canvas
        for sv in scrollviews {
            canvas.add(sv)
        }

        createSnapTargets()
    }

    //MARK: Vignette
    func createVignette() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let img = C4Image("1vignette")!
        img.frame = canvas.frame
        sv.add(img)
        return sv
    }

    //gets called every time the top scrollview layer is scrolled, runs because we created an observer at the end of setup()
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //checks the context
        if context == &scrollviewOffsetContext {
            //casts the object to ISV
            let sv = object as! InfiniteScrollView
            //grabs the offset
            let offset = sv.contentOffset
            //for each layer running from bottom, to top
            for i in 0..<scrollviews.count-1 {
                //grab the layer
                let layer = scrollviews[i]
                //set the layer's offset based on the top layer's current position
                layer.contentOffset = CGPointMake(offset.x * speeds[i], 0.0)
            }
        }
    }

    //MARK: Snapping
    func createSnapTargets() {
        snapTargets = [CGFloat]()
        for i in 0...12 {
            snapTargets.append(CGFloat(Double(gapBetweenSigns) * Double(i)*canvas.width))
        }
    }

    func snapIfNeeded(x: CGFloat, _ scrollView: UIScrollView) {
        for target in snapTargets {
            let dist = abs(CGFloat(target) - x)
            if dist <= CGFloat(canvas.width/2.0) {
                scrollView.setContentOffset(CGPointMake(target,0), animated: true)
                delay(0.25) {
                    var index = Int(Double(target) / (self.canvas.width * Double(gapBetweenSigns)))
                    if index == 12 { index = 0 }
                    self.signLines.currentIndex = index
                    self.signLines.revealCurrentSignLines()
                }
                return
            }
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        snapIfNeeded(x, scrollView)
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let x = scrollView.contentOffset.x
            snapIfNeeded(x, scrollView)
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.signLines.hideCurrentSignLines()
    }

    //MARK: Go To
    func goto(selection: Int) {
        let target = canvas.width * Double(gapBetweenSigns) * Double(selection)

        let anim = C4ViewAnimation(duration: 3.0) { () -> Void in
            self.scrollviews.last?.contentOffset = CGPoint(x: CGFloat(target),y: 0)
        }
        anim.curve = .EaseOut
        anim.animate()
        
        signLines.currentIndex = selection
        delay(anim.duration) { () -> () in
                self.signLines.revealCurrentSignLines()
        }
    }
}