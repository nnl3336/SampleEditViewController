//
//  DrawingCanvas.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import UIKit

// GalleryViewController の外に置く
enum DrawingTool {
    case pen
    case eraser
}

class DrawingCanvas: UIView {

    var currentTool: DrawingTool = .pen
    private var lines: [Line] = []

    struct Line {
        var points: [CGPoint]
        var color: UIColor
        var width: CGFloat
    }

    private var currentLine: Line?

    // 描画開始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let start = touch.location(in: self)
        let color: UIColor = currentTool == .pen ? .white : .clear
        let width: CGFloat = currentTool == .pen ? 4 : 20
        currentLine = Line(points: [start], color: color, width: width)
    }

    // 描画移動
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, var line = currentLine else { return }
        let point = touch.location(in: self)
        line.points.append(point)
        currentLine = line
        lines.append(line)
        setNeedsDisplay()
    }

    // 描画
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineCap(.round)

        for line in lines {
            context.beginPath()
            for (i, point) in line.points.enumerated() {
                if i == 0 { context.move(to: point) }
                else { context.addLine(to: point) }
            }
            context.setLineWidth(line.width)
            if line.color == .clear {
                context.setBlendMode(.clear)
            } else {
                context.setBlendMode(.normal)
                context.setStrokeColor(line.color.cgColor)
            }
            context.strokePath()
        }
    }

    func undo() {
        if !lines.isEmpty {
            lines.removeLast()
            setNeedsDisplay()
        }
    }

    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }

    // ←これが必須！
    func renderToImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }
}
