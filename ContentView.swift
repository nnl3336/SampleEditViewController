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
    let doneButton = UIButton(type: .system)
    let toolBar = UIStackView()
    let imageView = UIImageView()
    let cropOverlay = UIView()

    let brightnessContainer = UIView()
    let filterContainer = UIView()
    let cropContainer = UIView()
    let drawingContainer = UIView()

    var currentTool: DrawingTool = .pen

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavBar()
        setupToolBar()
        setupImageView()
    }

    // MARK: - UI 更新
    private func updateEditUI() {
        // 各モードコンテナだけ隠す
        [brightnessContainer, filterContainer, cropContainer, drawingContainer].forEach {
            $0.isHidden = true
        }
        
        // ツールバーやcropOverlayなどはそのまま管理
        toolBar.isHidden = false
        cropOverlay.isHidden = true
        doneButton.isHidden = true

        switch editMode {
        case .drawing:
            drawingContainer.isHidden = false
            setupDrawingTools()
            showDoneButton()
            updateTitle("お絵描き")
        case .brightness:
            brightnessContainer.isHidden = false
            updateTitle("光度")
        case .filter:
            filterContainer.isHidden = false
            updateTitle("フィルター")
        case .crop:
            cropContainer.isHidden = false
            cropOverlay.isHidden = false
            showDoneButton()
            updateTitle("トリミング")
        case .none:
            updateTitle("ギャラリー")
        }
    }

    private func showDoneButton() {
        doneButton.isHidden = false
        doneButton.removeTarget(nil, action: nil, for: .allEvents)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        print("Done button shown") // <- これで出てるか確認
    }

    @objc private func doneButtonTapped() {
        switch editMode {
        case .drawing: applyDrawing()
        case .crop: applyCrop()
        default: break
        }
        editMode = .none
        updateEditUI()
    }

    // MARK: - お絵描き
    private func setupDrawingTools() {
        drawingContainer.subviews.forEach { $0.removeFromSuperview() }
        let penButton = UIButton(type: .system)
        penButton.setTitle("ペン", for: .normal)
        penButton.frame = CGRect(x: 20, y: 20, width: 80, height: 40)
        penButton.addTarget(self, action: #selector(selectPen), for: .touchUpInside)

        let eraserButton = UIButton(type: .system)
        eraserButton.setTitle("消しゴム", for: .normal)
        eraserButton.frame = CGRect(x: 120, y: 20, width: 100, height: 40)
        eraserButton.addTarget(self, action: #selector(selectEraser), for: .touchUpInside)

        let undoButton = UIButton(type: .system)
        undoButton.setTitle("Undo", for: .normal)
        undoButton.frame = CGRect(x: 240, y: 20, width: 80, height: 40)
        undoButton.addTarget(self, action: #selector(undoAction), for: .touchUpInside)

        [penButton, eraserButton, undoButton].forEach { drawingContainer.addSubview($0) }

        // 描画キャンバス
        if imageView.subviews.compactMap({ $0 as? DrawingCanvas }).isEmpty {
            let canvas = DrawingCanvas(frame: imageView.bounds)
            canvas.currentTool = currentTool
            canvas.backgroundColor = .clear
            canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.addSubview(canvas)
        }
    }

    @objc func selectPen() { currentTool = .pen; updateCanvasTool() }
    @objc func selectEraser() { currentTool = .eraser; updateCanvasTool() }
    @objc func undoAction() { imageView.subviews.compactMap { $0 as? DrawingCanvas }.forEach { $0.undo() } }

    private func updateCanvasTool() {
        imageView.subviews.compactMap { $0 as? DrawingCanvas }.forEach { $0.currentTool = currentTool }
    }

    @objc func applyDrawing() {
        guard let img = imageView.image else { return }
        let canvas = imageView.subviews.compactMap { $0 as? DrawingCanvas }.first
        let drawingImage = canvas?.renderToImage(size: imageView.bounds.size) ?? UIImage()
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0)
        img.draw(in: CGRect(origin: .zero, size: imageView.bounds.size))
        drawingImage.draw(in: CGRect(origin: .zero, size: imageView.bounds.size))
        let merged = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = merged
        canvas?.clear()
    }

    // MARK: - トリミング
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
        cropOverlay.frame = CGRect(x: 20, y: 20, width: 160, height: 160)
    }

    // MARK: - NavBar
    func setupNavBar() {
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = UIColor.red.withAlphaComponent(0.5) // 半透明赤
        doneButton.backgroundColor = UIColor.blue.withAlphaComponent(0.5) // 半透明青
        view.addSubview(navBar)
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 88)
        ])
        imageView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        drawingContainer.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)

        navTitleLabel.textColor = .white
        navTitleLabel.font = .boldSystemFont(ofSize: 18)
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(navTitleLabel)
        NSLayoutConstraint.activate([
            navTitleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            navTitleLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
        ])

        doneButton.setTitle("完了", for: .normal)
        doneButton.tintColor = .white
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
        ])
        doneButton.isHidden = true
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
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])

        cropOverlay.layer.borderColor = UIColor.systemBlue.cgColor
        cropOverlay.layer.borderWidth = 2
        cropOverlay.backgroundColor = .clear
        cropOverlay.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(cropOverlay)
        cropOverlay.frame = CGRect(x: 20, y: 20, width: 160, height: 160)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleCropPan(_:)))
        cropOverlay.addGestureRecognizer(pan)
        cropOverlay.isHidden = true
    }

    @objc func selectDrawing() { editMode = .drawing }
    @objc func selectFilter() { editMode = .filter }
    @objc func selectCrop() { editMode = .crop }
    @objc func selectBrightness() { editMode = .brightness }
    func updateTitle(_ text: String) { navTitleLabel.text = text }
    @objc func handleCropPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: imageView)
        if let view = sender.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            sender.setTranslation(.zero, in: imageView)
        }
    }
}
