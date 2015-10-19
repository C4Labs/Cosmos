//
//  StarsBig.swift
//  Cosmos
//
//  Created by travis on 2015-10-19.
//  Copyright © 2015 C4. All rights reserved.
//

import C4
import UIKit

public class StarsBig : InfiniteScrollView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Creates empty scrollview to return
        clipsToBounds = false
        
        var signOrder = AstrologicalSignProvider.sharedInstance.order
        //sets the contents size to signCount * single size, adds canvas.width to account for overlap to hide snap
        contentSize = CGSizeMake(frame.size.width * (1.0 + CGFloat(signOrder.count) * gapBetweenSigns), 1.0)
        
        signOrder.append(signOrder[0])
        
        for i in 0..<signOrder.count {
            let dx = Double(i) * Double(frame.size.width  * gapBetweenSigns)
            let t = C4Transform.makeTranslation(C4Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            if var sign = AstrologicalSignProvider.sharedInstance.get(signOrder[i]) {
                for point in sign.big {
                    let img = C4Image("7bigStar")!
                    var p = point
                    p.transform(t)
                    img.center = p
                    add(img)
                }
            }
        }
        
        addDashesMarker()
        addSignNames()
    }
    
    func addDashesMarker() {
        let points = (C4Point(0,Double(frame.maxY)),C4Point(Double(contentSize.width),Double(frame.maxY)))
        let dashes = C4Line(points)
        dashes.lineDashPattern = [0.75,3.25]
        dashes.lineWidth = 10
        dashes.strokeColor = cosmosblue
        dashes.opacity = 0.33
        dashes.lineCap = .Butt
        
        let highdashes = C4Line(points)
        highdashes.lineDashPattern = [1,31]
        highdashes.lineWidth = 20
        highdashes.strokeColor = cosmosblue
        highdashes.lineCap = .Butt
        dashes.add(highdashes)
        
        let marker = C4Line(points)
        marker.lineDashPattern = [1.0,Double(frame.size.width * gapBetweenSigns)-1.0]
        marker.lineWidth = 40
        marker.strokeColor = white
        marker.lineDashPhase = Double(-frame.size.width/2)
        marker.lineCap = .Butt
        marker.opacity = 0.33
        marker.origin = C4Point(0,Double(frame.size.height))
        
        add(dashes)
        add(marker)
    }
    
    func addSignNames() {
        var signNames = AstrologicalSignProvider.sharedInstance.order
        signNames.append(signNames[0])
        
        let y = Double(frame.size.height - 86.0)
        let dx = Double(frame.size.width * gapBetweenSigns)
        let offset = Double(frame.size.width / 2.0)
        let font = C4Font(name:"Menlo-Regular", size: 13.0)!
        
        for i in 0..<signNames.count {
            let name = signNames[i]
            var point = C4Point(offset + dx * Double(i),y)
            
            if let sign = self.createSmallSign(name) {
                sign.center = point
                add(sign)
            }
            
            point.y += 26.0
            
            let title = self.createSmallSignTitle(name, font: font)
            title.center = point
            
            point.y+=22.0
            
            var value = i * 30
            if value > 330 { value = 0 }
            let degree = self.createSmallSignDegree(value, font: font)
            degree.center = point
            
            add(title)
            add(degree)
        }
    }
    
    func createSmallSign(name: String) -> C4Shape? {
        var smallSign : C4Shape?
        
        if let sign = AstrologicalSignProvider.sharedInstance.get(name)?.shape {
            sign.lineWidth = 2
            sign.strokeColor = white
            sign.fillColor = clear
            sign.opacity = 0.33
            sign.transform = C4Transform.makeScale(0.66, 0.66, 0)
            smallSign = sign
        }
        return smallSign
    }
    
    func createSmallSignTitle(name: String, font: C4Font) -> C4TextShape {
        let text = C4TextShape(text:name, font:font)!
        text.fillColor = white
        text.lineWidth = 0
        text.opacity = 0.33
        return text
    }
    
    func createSmallSignDegree(degree: Int, font: C4Font) -> C4TextShape {
        return createSmallSignTitle("\(degree)°", font: font)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}