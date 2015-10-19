//
//  StarsSmall.swift
//  Cosmos
//
//  Created by travis on 2015-10-19.
//  Copyright © 2015 C4. All rights reserved.
//

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
            if var sign = AstrologicalSignProvider.sharedInstance.get(signOrder[i]) {
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