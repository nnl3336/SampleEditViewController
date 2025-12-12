//
//  ContentView.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import SwiftUI
import CoreData

import UIKit

class GalleryViewController: UIViewController {
    
    var editMode: EditMode = .none {
        didSet { updateUIForMode() }
    }
    
    enum EditMode {
        case none, crop
    }
    
    let navBar = UIView()
    let navTitleLabel = UILabel()
    let doneButton = UIButton(type: .system)
    
    let toolBar = UIStackView()
    let cropButton = UIButton(type: .system)
    
    // トリミングビュー
    let cropView = UIView()
    let imageView = UIImageView()
    
    // トリミング枠
    let cropOverlay = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavBar()
        setupToolBar()
        setupCropView()
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
        
        // Title
        navTitleLabel.textColor = .white
        navTitleLabel.font = .boldSystemFont(ofSize: 18)
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(navTitleLabel)
        NSLayoutConstraint.activate([
            navTitleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            navTitleLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
        ])
        
        // Done
        doneButton.setTitle("完了", for: .normal)
        doneButton.tintColor = .white
        doneButton.addTarget(self, action: #selector(applyCrop), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
        ])
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
        
        cropButton.setTitle("トリミング", for: .normal)
        cropButton.tintColor = .white
        cropButton.addTarget(self, action: #selector(selectCrop), for: .touchUpInside)
        toolBar.addArrangedSubview(cropButton)
    }
    
    // MARK: - Crop View
    func setupCropView() {
        cropView.translatesAutoresizingMaskIntoConstraints = false
        cropView.backgroundColor = UIColor.darkGray
        view.addSubview(cropView)
        NSLayoutConstraint.activate([
            cropView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            cropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cropView.bottomAnchor.constraint(equalTo: toolBar.topAnchor)
        ])
        
        // 画像
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cropView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: cropView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: cropView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: cropView.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: cropView.heightAnchor, multiplier: 0.8)
        ])
        
        // トリミング枠
        cropOverlay.layer.borderColor = UIColor.systemBlue.cgColor
        cropOverlay.layer.borderWidth = 2
        cropOverlay.backgroundColor = UIColor.clear
        cropOverlay.translatesAutoresizingMaskIntoConstraints = false
        cropView.addSubview(cropOverlay)
        
        // 初期サイズ
        cropOverlay.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
        
        // ドラッグジェスチャー
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleCropPan(_:)))
        cropOverlay.addGestureRecognizer(pan)
    }
    
    @objc func selectCrop() {
        editMode = .crop
        navTitleLabel.text = "トリミング"
        doneButton.isHidden = false
        cropOverlay.isHidden = false
    }
    
    @objc func handleCropPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: cropView)
        if let view = sender.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            sender.setTranslation(.zero, in: cropView)
        }
    }
    
    @objc func applyCrop() {
        guard let image = imageView.image else { return }
        
        // 画像の表示サイズに合わせてスケーリング
        let imageFrame = imageView.frame
        let scaleX = image.size.width / imageFrame.width
        let scaleY = image.size.height / imageFrame.height
        
        let cropRect = CGRect(
            x: (cropOverlay.frame.origin.x - imageFrame.origin.x) * scaleX,
            y: (cropOverlay.frame.origin.y - imageFrame.origin.y) * scaleY,
            width: cropOverlay.frame.width * scaleX,
            height: cropOverlay.frame.height * scaleY
        )
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            let croppedImage = UIImage(cgImage: cgImage)
            imageView.image = croppedImage
            
            // 枠を元サイズにリセット
            cropOverlay.frame = CGRect(
                x: imageView.frame.minX + 20,
                y: imageView.frame.minY + 20,
                width: imageView.frame.width - 40,
                height: imageView.frame.height - 40
            )
        }
    }
    
    func updateUIForMode() {
        cropOverlay.isHidden = (editMode != .crop)
    }
}
