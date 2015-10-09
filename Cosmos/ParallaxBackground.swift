//
//  ParallaxBackground.swift
//  Cosmos
//
//  Created by travis on 2015-08-26.
//  Copyright © 2015 C4. All rights reserved.
//

import UIKit
import C4

class ParallaxBackground : C4CanvasController, UIScrollViewDelegate {
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

    lazy var signProvider = AstrologicalSignProvider()
    lazy var signLines = [[C4Line]]()
    lazy var currentSignLines = [C4Line]()
    lazy var snapTargets = [CGFloat]()

    override func setup() {
        //changes background color (specified in main view controller)
        canvas.backgroundColor = cosmosbkgd

        //adds layers to parallax background
        scrollviews.append(createBackgroundStars(0, imageName: "0Star", starCount: 20))
        scrollviews.append(createVignette())
        scrollviews.append(createBackgroundStars(2, imageName: "2Star", starCount: 20))
        scrollviews.append(createBackgroundStars(3, imageName: "3Star", starCount: 20))
        scrollviews.append(createBackgroundStars(4, imageName: "4Star", starCount: 20))
        scrollviews.append(createSignLines())
        scrollviews.append(createSmallStars())
        scrollviews.append(createBigStars())
        //adds all layers to the canvas
        for sv in scrollviews {
            canvas.add(sv)
        }

        //adds observer to the top layer, checks to see if the view has been scrolled
        if let topLayer = scrollviews.last {
            topLayer.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &scrollviewOffsetContext)
            topLayer.contentOffset = CGPointMake(view.frame.size.width * CGFloat(gapBetweenSigns / 2.0), 0)
        }

        createSnapTargets()
    }

    //Creates and returns a background star layer based on provided parameters
    func createBackgroundStars(index: Int, imageName: String, starCount: Int) -> InfiniteScrollView {
        var frame = view.frame
        //Calculates the frame size for the view
        let frameSize = frame.width * speeds[index]
        //Resets the frame size before applying it to create a scrollview
        frame.size.width = frameSize
        //Creates empty scrollview to return
        let sv = InfiniteScrollView(frame: frame)
        sv.clipsToBounds = false
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

    //MARK: Vignette
    func createVignette() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let img = C4Image("1Vignette")
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

    //MARK: Small Stars
    func createSmallStars() -> InfiniteScrollView {
        var frame = view.frame
        //Calculates the frame size for the view
        let frameSize = frame.width * speeds[6]
        //Resets the frame size before applying it to create a scrollview
        frame.size.width = frameSize
        //Creates empty scrollview to return
        let sv = InfiniteScrollView(frame: frame)
        sv.clipsToBounds = false
        //sets the contents size to signCount * single size, adds canvas.width to account for overlap to hide snap
        sv.contentSize = CGSizeMake(sv.frame.size.width * (1.0 + signCount * CGFloat(gapBetweenSigns)), 1.0)

        print(sv.contentSize)

        var signOrder = signProvider.order
        signOrder.append(signOrder[0])

        for i in 0..<signOrder.count {
            let dx = Double(i) * canvas.width * Double(speeds[6]) * Double(gapBetweenSigns)
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(signOrder[i]) {
                for point in sign.small {
                    let img = C4Image("6smallStar")
                    var p = point
                    p.transform(t)
                    img.center = p
                    sv.add(img)
                }
            }
        }
        return sv
    }

    //MARK: Big Stars
    func createBigStars() -> InfiniteScrollView {
        let bigStars = InfiniteScrollView(frame: view.frame)
        bigStars.contentSize = CGSizeMake(bigStars.frame.size.width * (1.0 + signCount * CGFloat(gapBetweenSigns)), 1.0)
        bigStars.showsHorizontalScrollIndicator = false

        var signOrder = signProvider.order
        signOrder.append(signOrder[0])

        for i in 0..<signOrder.count {
            let dx = Double(i) * canvas.width * Double(gapBetweenSigns)
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(signOrder[i]) {
                for point in sign.big {
                    let img = C4Image("7bigStar")
                    var p = point
                    p.transform(t)
                    img.center = p
                    bigStars.add(img)
                }
            }
        }

            addDashesMarker(bigStars)
            addSignNames(bigStars)

            bigStars.delegate = self
        return bigStars
    }

    func createSignLines() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        sv.contentSize = CGSizeMake(sv.frame.size.width * signCount * CGFloat(gapBetweenSigns) + sv.frame.size.width, 1.0)

        var signOrder = signProvider.order
        signOrder.append(signOrder[0])

        for i in 0..<signOrder.count {
            let dx = Double(i) * canvas.width * Double(gapBetweenSigns)
            let t = C4Transform.makeTranslation(C4Vector(x: canvas.center.x + dx, y: canvas.center.y, z: 0))
            if let sign = signProvider.get(signOrder[i]) {
                let connections = sign.lines

                var currentLineSet = [C4Line]()
                for points in connections {
                    var begin = points[0]
                    begin.transform(t)

                    var end = points[1]
                    end.transform(t)

                    let line = C4Line([begin,end])
                    line.lineWidth = 1.0
                    line.strokeColor = cosmosprpl
                    line.opacity = 0.4
                    line.strokeEnd = 0.0

                    sv.add(line)
                    currentLineSet.append(line)
                }
                signLines.append(currentLineSet)
            }
        }
        return sv
    }

    func addDashesMarker(sv: InfiniteScrollView) {
        let points = [C4Point(0,0),C4Point(Double(sv.contentSize.width),0)]

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
        marker.lineDashPattern = [1.0,canvas.width * Double(gapBetweenSigns)-1.0]
        marker.lineWidth = 40
        marker.strokeColor = white
        marker.lineDashPhase = -canvas.width/2
        marker.lineCap = .Butt
        marker.opacity = 0.33
        marker.origin = C4Point(0,canvas.height)

        dashes.origin = marker.origin
        sv.add(dashes)
        sv.add(marker)
    }

    func addSignNames(sv: InfiniteScrollView) {
        var signNames = signProvider.order
        signNames.append(signNames[0])

        let y = self.canvas.height - 86.0
        let dx = canvas.width*Double(gapBetweenSigns)
        let offset = self.canvas.width / 2.0
        let font = C4Font(name:"Menlo-Regular", size: 13.0)

        for i in 0..<signNames.count {
            let name = signNames[i]
            var point = C4Point(offset+dx*Double(i),y)

            if let sign = self.createSmallSign(name) {
                sign.center = point
                sv.add(sign)
            }

            point.y += 26.0

            let title = self.createSmallSignTitle(name, font: font)
            title.center = point

            point.y+=22.0

            var value = i * 30
            if value > 330 { value = 0 }
            let degree = self.createSmallSignDegree(value, font: font)
            degree.center = point

            sv.add(title)
            sv.add(degree)
        }
    }

    func createSmallSign(name: String) -> C4Shape? {
        var smallSign : C4Shape?

        if let sign = self.signProvider.get(name)?.shape {
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
        let text = C4TextShape(text:name, font:font)
        text.fillColor = white
        text.lineWidth = 0
        text.opacity = 0.33
        return text
    }

    func createSmallSignDegree(degree: Int, font: C4Font) -> C4TextShape {
        return createSmallSignTitle("\(degree)°", font: font)
    }

    //MARK: Snapping
    func createSnapTargets() {
        snapTargets.removeAll(keepCapacity: false)
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
                    var index = Int(Double(target) / (self.canvas.width * Double(self.gapBetweenSigns)))
                    if index == 12 { index = 0 }
                    self.currentSignLines = self.signLines[index]
                    self.revealCurrentSignLines()
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
        self.hideCurrentSignLines()
    }

    func revealCurrentSignLines() {
        C4ViewAnimation(duration: 0.25) {
            for line in self.currentSignLines {
                line.strokeEnd = 1.0
            }
        }.animate()
    }

    func hideCurrentSignLines() {
        C4ViewAnimation(duration: 0.25) {
            for line in self.currentSignLines {
                line.strokeEnd = 0.0
            }
        }.animate()
    }
}