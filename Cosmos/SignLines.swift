//
//  SignLines.swift
//  Cosmos
//
//  Created by travis on 2015-10-19.
//  Copyright © 2015 C4. All rights reserved.
//

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
