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

import UIKit
import C4

let cosmosprpl = C4Color(red:0.565, green: 0.075, blue: 0.996, alpha: 1.0)
let cosmosblue = C4Color(red: 0.094, green: 0.271, blue: 1.0, alpha: 1.0)
let cosmosbkgd = C4Color(red: 0.078, green: 0.118, blue: 0.306, alpha: 1.0)

class ViewController: C4CanvasController {
    var background : ParallaxBackground?
    var menu : Menu?
    var info : InfoPanel?

    var audio1 : C4AudioPlayer?
    var audio2 : C4AudioPlayer?

    override func setup() {
        canvas.backgroundColor = cosmosbkgd

        background = ParallaxBackground()
        canvas.add(background?.canvas)

        menu = Menu()
        menu?.canvas.center = canvas.center
        canvas.add(menu?.canvas)

        info = InfoPanel()
        canvas.add(info?.canvas)

        menu?.selectionAction = background?.goto
        menu?.infoAction = info?.show

        audio1 = C4AudioPlayer("audio1.mp3")
        audio1?.loops = true
        audio1?.play()

        audio2 = C4AudioPlayer("audio2.mp3")
        audio2?.loops = true
        audio2?.play()
    }
}