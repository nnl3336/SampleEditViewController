//
//  ContentView.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import UIKit
import CoreData

final class GalleryViewController: UIViewController {

    // ==================================================
    // viewDidLoad()
    // ==================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupNavBar()
        setupToolBar()
        setupImageView()
        setupContainers()
        setupGesture()
        setupData()
        setupFRC()

        updateUI()
        updateNavBar()
        updateToolBar()
    }

    // ==================================================
    //基本プロパティ
    // ==================================================
    
    enum DrawingTool {
        case pen
        case eraser
    }
    private var drawingTool: DrawingTool = .pen {
        didSet {
            updateDrawingTool()
        }
    }

    private var penColor: UIColor = .systemRed
    private var penWidth: CGFloat = 4.0

    private var eraserWidth: CGFloat = 10.0
    
    private let canvasView = CanvasView()  // ←ここに置く

    
    // ==================================================
    // Toolbars
    // ==================================================
    private let mainBar = UIStackView()
    private let drawingBar = UIStackView()
    private let filterBar = UIStackView()
    private let cropBar = UIStackView()
    private let brightnessBar = UIStackView()


    // MARK: - Edit State
    enum EditState {
        case none
        case drawing
        case filter
        case crop
        case brightness
    }

    private var editMode: EditState = .none {
        didSet {
            updateEditUI()
        }
    }

    // MARK: - UI
    private let navBar = UIView()
    private let navTitleLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let toolBar = UIStackView()
    private let imageView = UIImageView()

    private let brightnessContainer = UIView()
    private let filterContainer = UIView()
    private let cropContainer = UIView()
    private let drawingContainer = UIView()

    private let cropOverlay = CropOverlay(
        frame: CGRect(x: 20, y: 20, width: 160, height: 160)
    )

    // MARK: - Data
    private var frc: NSFetchedResultsController<NSManagedObject>?
    private var isEditingMode: Bool = false
}

extension GalleryViewController {
    
    @objc func selectPen() {
        drawingTool = .pen
    }

    @objc func selectEraser() {
        drawingTool = .eraser
    }

    private func updateDrawingTool() {
        switch drawingTool {
        case .pen:
            canvasView.tool = .pen
        case .eraser:
            canvasView.tool = .eraser
        }
    }

}

// ==================================================
// update
// ==================================================

extension GalleryViewController {

    // updateUI
    func updateUI() {
        view.backgroundColor = .black
        updateEditUI()
    }

    // updateNavBar
    func updateNavBar() {
        navTitleLabel.textColor = .white
    }

    // updateToolBar
    func updateToolBar() {
        toolBar.isHidden = false
    }

    // Edit UI 更新　//updateUI
    private func updateEditUI() {
        updateContainers()
        updateToolBarForMode()
        updateNavigationTitle()
    }
    
    //updateToolBar
    private func updateToolBarForMode() {

        // ① まず全バーを隠す
        [mainBar, drawingBar, filterBar, cropBar, brightnessBar].forEach {
            $0.isHidden = true
        }

        // ② モードに応じて1つだけ表示
        switch editMode {
        case .none:
            mainBar.isHidden = false

        case .drawing:
            drawingBar.isHidden = false

        case .filter:
            filterBar.isHidden = false

        case .crop:
            cropBar.isHidden = false

        case .brightness:
            brightnessBar.isHidden = false
        }
    }

    
    private func updateNavigationTitle() {
        switch editMode {
        case .drawing:
            updateTitle("お絵描き")
        case .filter:
            updateTitle("フィルター")
        case .crop:
            updateTitle("トリミング")
        case .brightness:
            updateTitle("光度")
        case .none:
            updateTitle("ギャラリー")
        }
    }


    
    private func updateContainers() {
        brightnessContainer.isHidden = editMode != .brightness
        filterContainer.isHidden     = editMode != .filter
        cropContainer.isHidden       = editMode != .crop
        drawingContainer.isHidden    = editMode != .drawing

        cropOverlay.isHidden = editMode != .crop
    }


    private func updateTitle(_ text: String) {
        navTitleLabel.text = text
    }
}

// ==================================================
// setup
// ==================================================

extension GalleryViewController {

    // setupUI
    func setupUI() {
        view.backgroundColor = .black
    }

    // setupNavBar
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

    // setupToolBar
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
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tintColor = .white
            button.addTarget(self, action: action, for: .touchUpInside)
            toolBar.addArrangedSubview(button)
        }
    }

    // setupImageView
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

        cropOverlay.layer.borderColor = UIColor.systemBlue.cgColor
        cropOverlay.layer.borderWidth = 2
        cropOverlay.backgroundColor = .clear
        cropOverlay.isHidden = true
        imageView.addSubview(cropOverlay)
    }

    // setupContainers
    func setupContainers() {
        [drawingContainer, filterContainer, cropContainer, brightnessContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .secondarySystemBackground
            view.addSubview($0)

            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                $0.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
    }

    // setupGesture
    func setupGesture() {
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleCropPan(_:))
        )
        cropOverlay.addGestureRecognizer(pan)
    }

    // setupData
    func setupData() {
        // 初期データ処理
    }

    // setupFRC
    func setupFRC() {
        // NSFetchedResultsController 初期化
    }
}

// ==================================================
// actions
// ==================================================

extension GalleryViewController {

    @objc func saveAction() {
        print("保存 tapped")
    }

    @objc func selectDrawing() {
        editMode = .drawing
    }

    @objc func selectFilter() {
        editMode = .filter
    }

    @objc func selectCrop() {
        editMode = .crop
    }

    @objc func selectBrightness() {
        editMode = .brightness
    }

    @objc func handleCropPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: imageView)
        guard let view = sender.view else { return }

        var newCenter = CGPoint(
            x: view.center.x + translation.x,
            y: view.center.y + translation.y
        )

        newCenter.x = max(
            view.frame.width / 2,
            min(imageView.bounds.width - view.frame.width / 2, newCenter.x)
        )
        newCenter.y = max(
            view.frame.height / 2,
            min(imageView.bounds.height - view.frame.height / 2, newCenter.y)
        )

        view.center = newCenter
        sender.setTranslation(.zero, in: imageView)
    }
}

//

// 1本の線を表す構造体
struct Line {
    var points: [CGPoint]       // 線のポイント
    var color: UIColor          // 線の色
    var width: CGFloat          // 線の太さ
    var tool: DrawingTool       // ペン or 消しゴム
}

private let canvasView = CanvasView()

// CanvasView は UIView のサブクラスで描画処理を持つ
class CanvasView: UIView {
    private var lines: [Line] = []
    var strokeColor: UIColor = .black
    var strokeWidth: CGFloat = 5
    var tool: DrawingTool = .pen

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 新しい線を開始
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 線を追加
    }

    override func draw(_ rect: CGRect) {
        // 線を描画
    }
}

