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

class ParallaxBackground : C4CanvasController {
    //Specifies how quickly each layer moves, relative to top layer, order = [bottom, ..., top]
    var speeds : [CGFloat] = [0.08,0.0,0.10,0.12,0.15,1.0,0.8,1.0]
    //array of infinite scrollview layers
    lazy var scrollviews = [InfiniteScrollView]()
    //number of astrological signs in the app
    let signCount : CGFloat = 12.0
    //distance between signs (e.g. 10 app window frames)
    lazy var gapBetweenSigns : CGFloat = 10.0
    //variable used for marking observeValueForKeyPath
    var scrollviewOffsetContext = 0

    override func setup() {
        //changes background color (specified in main view controller)
        canvas.backgroundColor = cosmosbkgd

        //adds layers to parallax background
        scrollviews.append(createBackgroundStars(0, imageName: "0Star", starCount: 20))
        scrollviews.append(createBackgroundStars(1, imageName: "1Vignette", starCount: 0))
        scrollviews.append(createBackgroundStars(2, imageName: "2Star", starCount: 20))
        scrollviews.append(createBackgroundStars(3, imageName: "3Star", starCount: 20))
        scrollviews.append(createBackgroundStars(4, imageName: "4Star", starCount: 20))

        //adds all layers to the canvas
        for sv in scrollviews {
            canvas.add(sv)
        }

        //adds observer to the top layer, checks to see if the view has been scrolled
        if let topLayer = scrollviews.last {
            topLayer.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &scrollviewOffsetContext)
        }
    }

    //Creates and returns a background star layer based on provided parameters
    func createBackgroundStars(index: Int, imageName: String, starCount: Int) -> InfiniteScrollView {
        //Creates empty scrollview to return
        let sv = InfiniteScrollView(frame: view.frame)
        //Calculates the frame size for the view
        let frameSize = sv.frame.width * speeds[index]
        //Calculates size of single sign and its content (including gap to next sign)
        let singleSignContentSize = frameSize * gapBetweenSigns
        //sets the contents size to signCount * single size, adds canvas.width to account for overlap to hide snap
        sv.contentSize = CGSizeMake(singleSignContentSize * signCount + CGFloat(canvas.width), 1.0)

        //for every frame
        for currentFrame in 0..<Int(signCount) {
            //calculate the current offset
            let dx = Double(singleSignContentSize) * Double(currentFrame)
            //then for the number of specified stars we need
            for _ in 0..<starCount {
                //create an x position based on current offset
                let x = dx + random01() * Double(singleSignContentSize)
                //create a random y position
                let y = random01() * canvas.height
                //create a point
                var pt = C4Point(x, y)
                //create an image using the specified name
                let img = C4Image(imageName)
                //center the image to the random point
                img.center = pt
                //add the image to the canvas
                sv.add(img)
                //if the image falls within the first view's frame (e.g. 0 < x < 320)
                if pt.x < canvas.width {
                    //shift x by the entire content size
                    pt.x += Double(signCount * singleSignContentSize)
                    //create a new image
                    let img = C4Image(imageName)
                    //center it
                    img.center = pt
                    //add it
                    sv.add(img)
                }
            }
        }
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
}