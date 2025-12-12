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
        imageView.layer.borderColor = UIColor.white.cgColor   // 線の色
        imageView.layer.borderWidth = 1.0                      // 線の太さ
        imageView.layer.cornerRadius = 0                       // 丸めたい場合は変更
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
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
    @objc func selectCrop() { editMode = .crop }
    @objc func selectBrightness() { editMode = .brightness }
}
