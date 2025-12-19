//
//  CropOverlay.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import UIKit

// CropOverlay クラス
class CropOverlay: UIView {

    private let minSize: CGFloat = 50

    // 角
    private let topLeft = UIView(), topRight = UIView(), bottomLeft = UIView(), bottomRight = UIView()
    // 辺の中間
    private let topCenter = UIView(), bottomCenter = UIView(), leftCenter = UIView(), rightCenter = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = 2
        backgroundColor = .clear
        setupHandles()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupHandles() {
        let handles = [topLeft, topRight, bottomLeft, bottomRight,
                       topCenter, bottomCenter, leftCenter, rightCenter]

        handles.forEach {
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.borderWidth = 1
            $0.frame.size = CGSize(width: 20, height: 20)
            addSubview($0)
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            $0.addGestureRecognizer(pan)
        }
        positionHandles()
        
        // overlay 自身の pan（移動用）
        let movePan = UIPanGestureRecognizer(target: self, action: #selector(moveOverlay(_:)))
        addGestureRecognizer(movePan)
    }

    func positionHandles() {
        topLeft.frame.origin = CGPoint(x: -10, y: -10)
        topRight.frame.origin = CGPoint(x: bounds.width-10, y: -10)
        bottomLeft.frame.origin = CGPoint(x: -10, y: bounds.height-10)
        bottomRight.frame.origin = CGPoint(x: bounds.width-10, y: bounds.height-10)
        
        topCenter.frame.origin = CGPoint(x: bounds.width/2-10, y: -10)
        bottomCenter.frame.origin = CGPoint(x: bounds.width/2-10, y: bounds.height-10)
        leftCenter.frame.origin = CGPoint(x: -10, y: bounds.height/2-10)
        rightCenter.frame.origin = CGPoint(x: bounds.width-10, y: bounds.height/2-10)
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let handle = sender.view else { return }
        let translation = sender.translation(in: self)
        sender.setTranslation(.zero, in: self)
        var newFrame = frame

        switch handle {
        case topLeft:
            newFrame.origin.x += translation.x
            newFrame.origin.y += translation.y
            newFrame.size.width -= translation.x
            newFrame.size.height -= translation.y
        case topRight:
            newFrame.origin.y += translation.y
            newFrame.size.width += translation.x
            newFrame.size.height -= translation.y
        case bottomLeft:
            newFrame.origin.x += translation.x
            newFrame.size.width -= translation.x
            newFrame.size.height += translation.y
        case bottomRight:
            newFrame.size.width += translation.x
            newFrame.size.height += translation.y
        case topCenter:
            newFrame.origin.y += translation.y
            newFrame.size.height -= translation.y
        case bottomCenter:
            newFrame.size.height += translation.y
        case leftCenter:
            newFrame.origin.x += translation.x
            newFrame.size.width -= translation.x
        case rightCenter:
            newFrame.size.width += translation.x
        default:
            break
        }

        // 最小サイズ制限
        if newFrame.width >= minSize && newFrame.height >= minSize {
            frame = newFrame
            positionHandles()
        }
    }

    @objc private func moveOverlay(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        sender.setTranslation(.zero, in: superview)
        var newFrame = frame
        newFrame.origin.x += translation.x
        newFrame.origin.y += translation.y

        // 親ビュー内に収める
        if let parent = superview {
            newFrame.origin.x = max(0, min(parent.bounds.width - newFrame.width, newFrame.origin.x))
            newFrame.origin.y = max(0, min(parent.bounds.height - newFrame.height, newFrame.origin.y))
        }

        frame = newFrame
        positionHandles()
    }
}
