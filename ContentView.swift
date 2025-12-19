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
    // 基本プロパティ
    // ==================================================

    enum EditState { case none, drawing, filter, crop, brightness }

    private var editMode: EditState = .none {
        didSet { updateEditUI() }
    }

    // UI
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

    // Data
    private var frc: NSFetchedResultsController<NSManagedObject>?
    private var isEditingMode: Bool = false
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

    // Edit UI 更新
    private func updateEditUI() {
        brightnessContainer.isHidden = editMode != .brightness
        filterContainer.isHidden = editMode != .filter
        cropContainer.isHidden = editMode != .crop
        drawingContainer.isHidden = editMode != .drawing

        cropOverlay.isHidden = editMode != .crop

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
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.tintColor = .white
            btn.addTarget(self, action: action, for: .touchUpInside)
            toolBar.addArrangedSubview(btn)
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
