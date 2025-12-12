//
//  ContentView.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import UIKit

class GalleryViewController: UIViewController {

    enum EditState { case none, drawing, filter, crop, brightness }
    var editMode: EditState = .none { didSet { updateEditUI() } }

    let navBar = UIView()
    let navTitleLabel = UILabel()
    let saveButton = UIButton(type: .system)
    let toolBar = UIStackView()
    let imageView = UIImageView()

    let brightnessContainer = UIView()
    let filterContainer = UIView()
    let cropContainer = UIView()
    let drawingContainer = UIView()
    
    let cropOverlay = CropOverlay(frame: CGRect(x: 20, y: 20, width: 160, height: 160))


    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black
            setupNavBar()
            setupToolBar()
            setupImageView()
            setupContainers()
            
            // 初期状態
            editMode = .none
            updateEditUI()
            
            // CropOverlay を imageView に追加
            imageView.addSubview(cropOverlay)
            cropOverlay.isHidden = true
        }

    // MARK: - UI 更新
    private func updateEditUI() {
        // モードに応じて表示するビューだけを表示
        brightnessContainer.isHidden = editMode != .brightness
        filterContainer.isHidden = editMode != .filter
        cropContainer.isHidden = editMode != .crop
        drawingContainer.isHidden = editMode != .drawing

        // ツールバーは常に表示
        toolBar.isHidden = false

        // タイトル更新
        switch editMode {
        case .drawing: updateTitle("お絵描き")
        case .filter: updateTitle("フィルター")
        case .crop: updateTitle("トリミング")
        case .brightness: updateTitle("光度")
        case .none: updateTitle("ギャラリー")
        }
    }

    private func updateTitle(_ text: String) {
        navTitleLabel.text = text
    }

    // MARK: - NavBar
    func setupNavBar() {
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = .black
        view.addSubview(navBar)
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 88)
        ])

        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navTitleLabel.textColor = .white
        navTitleLabel.font = .boldSystemFont(ofSize: 18)
        navBar.addSubview(navTitleLabel)
        NSLayoutConstraint.activate([
            navTitleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            navTitleLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
        ])

        saveButton.setTitle("保存", for: .normal)
        saveButton.tintColor = .white
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        navBar.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
        ])
    }

    @objc func saveAction() {
        print("保存ボタン tapped")
    }

    // MARK: - Toolbar
    func setupToolBar() {
        toolBar.axis = .horizontal
        toolBar.alignment = .center
        toolBar.distribution = .equalSpacing
        toolBar.spacing = 20
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)
        NSLayoutConstraint.activate([
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toolBar.heightAnchor.constraint(equalToConstant: 60)
        ])

        let buttons: [(String, Selector)] = [
            ("お絵描き", #selector(selectDrawing)),
            ("フィルター", #selector(selectFilter)),
            ("トリミング", #selector(selectCrop)),
            ("光度", #selector(selectBrightness))
        ]
        buttons.forEach { title, action in
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.tintColor = .white
            btn.addTarget(self, action: action, for: .touchUpInside)
            toolBar.addArrangedSubview(btn)
        }
    }

    // MARK: - ImageView
    func setupImageView() {
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // トリミング枠（初期は非表示）
        cropOverlay.layer.borderColor = UIColor.systemBlue.cgColor
        cropOverlay.layer.borderWidth = 2
        cropOverlay.backgroundColor = .clear
        cropOverlay.frame = CGRect(x: 20, y: 20, width: 160, height: 160)
        imageView.addSubview(cropOverlay)
        cropOverlay.isHidden = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleCropPan(_:)))
        cropOverlay.addGestureRecognizer(pan)
    }
    

    
    // 角を示すハンドル
        let topLeftHandle = UIView()
        let topRightHandle = UIView()
        let bottomLeftHandle = UIView()
        let bottomRightHandle = UIView()

    // モード切替
    @objc func selectCrop() {
        editMode = .crop
        cropOverlay.isHidden = false
    }

    // パンジェスチャーで移動
    @objc func handleCropPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: imageView)
        if let view = sender.view {
            // 画像枠内に収める
            var newCenter = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            newCenter.x = max(view.frame.width/2, min(imageView.bounds.width - view.frame.width/2, newCenter.x))
            newCenter.y = max(view.frame.height/2, min(imageView.bounds.height - view.frame.height/2, newCenter.y))
            view.center = newCenter
            sender.setTranslation(.zero, in: imageView)
        }
    }

    // トリミング適用
    @objc func applyCrop() {
        guard let img = imageView.image else { return }
        let scaleX = img.size.width / imageView.frame.width
        let scaleY = img.size.height / imageView.frame.height
        
        let cropRect = CGRect(
            x: cropOverlay.frame.origin.x * scaleX,
            y: cropOverlay.frame.origin.y * scaleY,
            width: cropOverlay.frame.width * scaleX,
            height: cropOverlay.frame.height * scaleY
        )
        
        if let cg = img.cgImage?.cropping(to: cropRect) {
            imageView.image = UIImage(cgImage: cg)
        }
        
        // 枠を初期位置に戻す
        cropOverlay.frame = CGRect(x: 20, y: 20, width: 160, height: 160)
        cropOverlay.isHidden = true
    }

    // MARK: - モードコンテナ
    func setupContainers() {
        [drawingContainer, filterContainer, cropContainer, brightnessContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = [.systemRed, .systemYellow, .systemGreen, .systemBlue].randomElement()
            view.addSubview($0)
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                $0.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
    }

    @objc func selectDrawing() { editMode = .drawing }
    @objc func selectFilter() { editMode = .filter }
    @objc func selectBrightness() { editMode = .brightness }
}

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
