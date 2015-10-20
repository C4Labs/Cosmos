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

public class StarsSmall : InfiniteScrollView {
    
    
    convenience public init(frame: CGRect, speed: CGFloat) {
        self.init(frame: frame)

        //Creates empty scrollview to return
        clipsToBounds = false
        
        var signOrder = AstrologicalSignProvider.sharedInstance.order
        //sets the contents size to signCount * single size, adds canvas.width to account for overlap to hide snap
        contentSize = CGSizeMake(frame.size.width * (1.0 + CGFloat(signOrder.count) * gapBetweenSigns), 1.0)
        
        signOrder.append(signOrder[0])
        
        for i in 0..<signOrder.count {
            let dx = Double(i) * Double(frame.size.width * speed * gapBetweenSigns)
            let t = C4Transform.makeTranslation(C4Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            if let sign = AstrologicalSignProvider.sharedInstance.get(signOrder[i]) {
                for point in sign.small {
                    let img = C4Image("6smallStar")!
                    var p = point
                    p.transform(t)
                    img.center = p
                    add(img)
                }
            }
        }
    }

}