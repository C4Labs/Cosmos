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

public class SignLines : InfiniteScrollView {
    var lines : [[C4Line]]!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let count = CGFloat(AstrologicalSignProvider.sharedInstance.order.count)
        let width = frame.size.width
        let gap = CGFloat(gapBetweenSigns)
        
        contentSize = CGSizeMake(width * count * gap + width, 1.0)
        
        var signOrder = AstrologicalSignProvider.sharedInstance.order
        signOrder.append(signOrder[0])
        
        lines = [[C4Line]]()
        for i in 0..<signOrder.count {
            let dx = Double(i) * Double(frame.width) * Double(gapBetweenSigns)
            let t = C4Transform.makeTranslation(C4Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            if var sign = AstrologicalSignProvider.sharedInstance.get(signOrder[i]) {
                let connections = sign.lines
                
                var currentLineSet = [C4Line]()
                for points in connections {
                    var begin = points[0]
                    begin.transform(t)
                    
                    var end = points[1]
                    end.transform(t)
                    
                    let line = C4Line((begin,end))
                    line.lineWidth = 1.0
                    line.strokeColor = cosmosprpl
                    line.opacity = 0.4
                    line.strokeEnd = 0.0
                    
                    add(line)
                    currentLineSet.append(line)
                }
                lines.append(currentLineSet)
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func revealCurrentSignLines() {
        C4ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 1.0
            }
            }.animate()
    }
    
    func hideCurrentSignLines() {
        C4ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 0.0
            }
            }.animate()
    }

    var currentIndex : Int = 0
    
    var currentLines : [C4Line] {
        get {
            let set = lines[currentIndex]
            return set
        }
    }
}
