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

public class StarsBackground : InfiniteScrollView {
    
    convenience public init(frame: CGRect, imageName: String, starCount: Int, speed: CGFloat) {
        self.init(frame: frame)
        //Calculates the frame size for the view
        let frameSize = frame.width * speed
        //Creates empty scrollview to return
        clipsToBounds = false
        //Calculates size of single sign and its content (including gap to next sign)
        let singleSignContentSize = frameSize * gapBetweenSigns
        let width = frame.size.width
        let count = CGFloat(AstrologicalSignProvider.sharedInstance.order.count)
        
        //sets the contents size to signCount * single size, adds canvas.width to account for overlap to hide snap
        contentSize = CGSizeMake(singleSignContentSize * count + width, 1.0)
        
        //for every frame
        for currentFrame in 0..<Int(count) {
            //calculate the current offset
            let dx = Double(singleSignContentSize) * Double(currentFrame)
            //then for the number of specified stars we need
            for _ in 0..<starCount {
                //create an x position based on current offset
                let x = dx + random01() * Double(singleSignContentSize)
                //create a random y position
                let y = random01() * Double(frame.size.height)
                //create a point
                var pt = C4Point(x, y)
                //create an image using the specified name
                let img = C4Image(imageName)!
                //center the image to the random point
                img.center = pt
                //add the image to the canvas
                add(img)
                //if the image falls within the first view's frame (e.g. 0 < x < 320)
                if pt.x < Double(width) {
                    //shift x by the entire content size
                    pt.x += Double(count * singleSignContentSize)
                    //create a new image
                    let img = C4Image(imageName)!
                    //center it
                    img.center = pt
                    //add it
                    add(img)
                }
            }
        }
    }
}
