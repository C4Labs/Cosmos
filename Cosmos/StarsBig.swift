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

public class StarsBig : InfiniteScrollView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
       
        //grabs the current order
        var signOrder = AstrologicalSignProvider.sharedInstance.order
        //sets the contents size to signCount * single size, adds canvas.width to account for overlap to hide snap
        contentSize = CGSizeMake(frame.size.width * (1.0 + CGFloat(signOrder.count) * gapBetweenSigns), 1.0)
        
        //appends a copy of the first sign to the end of the order
        signOrder.append(signOrder[0])
        
        //adds all the big stars to the view
        for i in 0..<signOrder.count {
            //calculates the offset
            let dx = Double(i) * Double(frame.size.width  * gapBetweenSigns)
            //creates a transform
            let t = C4Transform.makeTranslation(C4Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            //grabs the current sign
            if let sign = AstrologicalSignProvider.sharedInstance.get(signOrder[i]) {
                //creates a new big star for each point
                for point in sign.big {
                    let img = C4Image("7bigStar")!
                    var p = point
                    p.transform(t)
                    img.center = p
                    add(img)
                }
            }
        }
        
        addDashes()
        addMarkers()
        addSignNames()
    }
    
    //adds the short blue dashes
    func addDashes() {
        //grabs the points for the bottom-left and bottom-right coordinates of the contentsize
        let points = (C4Point(0,Double(frame.maxY)),C4Point(Double(contentSize.width),Double(frame.maxY)))
        
        //creates a line of short dashes
        let dashes = C4Line(points)
        dashes.lineDashPattern = [2,6]
        dashes.lineWidth = 10
        dashes.strokeColor = cosmosblue
        dashes.opacity = 0.33
        dashes.lineCap = .Butt
        
        add(dashes)
    }
    
    //adds the tall white markers
    func addMarkers() {
        for i in 0..<AstrologicalSignProvider.sharedInstance.order.count {
            let dx = Double(i) * Double(frame.width * gapBetweenSigns) + Double(frame.width / 2.0)
            
            let begin = C4Point(dx,Double(frame.height-20.0))
            let end = C4Point(dx,Double(frame.height))
            
            let marker = C4Line((begin,end))
            marker.lineWidth = 2
            marker.strokeColor = white
            marker.lineCap = .Butt
            marker.opacity = 0.33
            add(marker)
        }
    }
    
    func addSignNames() {
        //grabs the sign names
        var signNames = AstrologicalSignProvider.sharedInstance.order
        //appends a copy of the first name to the end of the array
        signNames.append(signNames[0])
        
        //specify the y position of the sign
        let y = Double(frame.size.height - 86.0)
        //calculate the displacement to the current frame
        let dx = Double(frame.size.width * gapBetweenSigns)
        //define the offset to the center of the canvas
        let offset = Double(frame.size.width / 2.0)
        //create a font
        let font = C4Font(name:"Menlo-Regular", size: 13.0)!
        
        //for each of the names
        for i in 0..<signNames.count {
            //grab the current
            let name = signNames[i]

            //calculate the point for the sign
            var point = C4Point(offset + dx * Double(i),y)
            //grab the current sign (based on the name), add it to the view
            if let sign = self.createSmallSign(name) {
                sign.center = point
                add(sign)
            }

            //offset y by a bit
            point.y += 26.0

            //add a label for the current name
            let title = self.createSmallSignTitle(name, font: font)
            title.center = point

            //offset y by a little bit
            point.y+=22.0

            //calculate the current degrees
            var value = i * 30
            //if it is > 330, make it 0 so the the overlap is consistent with the first sign's label
            if value > 330 { value = 0 }
            //create a label for the degrees
            let degree = self.createSmallSignDegree(value, font: font)
            degree.center = point

            add(title)
            add(degree)
        }
    }
    
    func createSmallSign(name: String) -> C4Shape? {
        var smallSign : C4Shape?
        //try to extract a sign from the provider, and style it
        if let sign = AstrologicalSignProvider.sharedInstance.get(name)?.shape {
            sign.lineWidth = 2
            sign.strokeColor = white
            sign.fillColor = clear
            sign.opacity = 0.33
            //scale the sign down from its original size
            sign.transform = C4Transform.makeScale(0.66, 0.66, 0)
            smallSign = sign
        }
        return smallSign
    }
    
    //create a text shape from a name and a font
    func createSmallSignTitle(name: String, font: C4Font) -> C4TextShape {
        let text = C4TextShape(text:name, font:font)!
        text.fillColor = white
        text.lineWidth = 0
        text.opacity = 0.33
        return text
    }
    
    func createSmallSignDegree(degree: Int, font: C4Font) -> C4TextShape {
        //return a string with a little degree symbol
        return createSmallSignTitle("\(degree)°", font: font)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}