//
//  ViewController.swift
//  Cosmos
//
//  Created by travis on 2015-08-06.
//  Copyright © 2015 C4. All rights reserved.
//

import UIKit
import C4

class ViewController: C4CanvasController {

    let isv = InfiniteScrollView()

    override func setup() {
        isv.frame = CGRect(canvas.frame)
        canvas.add(isv)
        addVisualIndicators()
    }

    func addVisualIndicators() {
        let gap = 50.0
        let margin = 20.0 //margin
        let count = 20
        let width = Double(count + 1) * gap + margin
        let height = Double(count + 1) * gap + margin

        isv.contentSize = CGSizeMake(CGFloat(width-margin) + isv.frame.width, CGFloat(height-margin) + isv.frame.height)

        var y = 0

        while Double(y) * gap < Double(isv.contentSize.height) {
            var x = 0

            while Double(x) * gap < Double(isv.contentSize.width) {
                var n = 0
                n += x > count ? x - (count + 1) : x
                n += y > count ? y - (count + 1) : y

                if n > count {
                    n -= count+1
                }
                let point = C4Point(Double(x) * gap + margin, Double(y) * gap + margin)
                createIndicator("\(n)", at: point)
                x++
            }
            y++
        }
    }

    func createIndicator(text: String, at point: C4Point) {
        let f = C4Font(name: "Helvetica", size: 30)
        let ts = C4TextShape(text: text, font: f)
        ts.center = point
        isv.add(ts)
    }
}
