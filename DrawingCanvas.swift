//
//  DrawingCanvas.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import UIKit

// 描画用キャンバス
class DrawingCanvas: UIView {
    
    var currentTool: GalleryViewController.DrawingTool = .pen
    private var lines: [Line] = []
    private var undoneLines: [Line] = []
    
    struct Line {
        var points: [CGPoint]
        var color: UIColor
        var width: CGFloat
    }
    
    private var currentLine: Line?
    
    // タッチ開始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let start = touch.location(in: self)
        let color: UIColor = currentTool == .pen ? .white : .clear
        let width: CGFloat = currentTool == .pen ? 4 : 20
        currentLine = Line(points: [start], color: color, width: width)
    }
    
    // タッチ移動
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
    
    // Undo
    func undo() {
        if !lines.isEmpty {
            undoneLines.append(lines.removeLast())
            setNeedsDisplay()
        }
    }
    
    // 消去
    func clear() {
        lines.removeAll()
        undoneLines.removeAll()
        setNeedsDisplay()
    }
}
