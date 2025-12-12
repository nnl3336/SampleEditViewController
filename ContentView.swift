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
    
    enum EditState { case none, drawing, filter, crop, brightness }
    var editMode: EditState = .none {
        didSet { updateEditUI() }
    }
    
    let navBar = UIView()
    let navTitleLabel = UILabel()
    let doneButton = UIButton(type: .system)
    
    let toolBar = UIStackView()
    
    let imageView = UIImageView()
    
    // トリミング用オーバーレイ
    let cropOverlay = UIView()
    
    // モードごとのコンテナ
    let brightnessContainer = UIView()
    let filterContainer = UIView()
    let cropContainer = UIView()
    let drawingContainer = UIView()
    
    // お絵描きツール状態
    enum DrawingTool { case pen, eraser }
    var currentTool: DrawingTool = .pen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavBar()
        setupToolBar()
        setupImageView()
    }
    
    // MARK: - モード切替
    private func updateEditUI() {
        // 全部隠す
        brightnessContainer.isHidden = true
        filterContainer.isHidden = true
        cropContainer.isHidden = true
        drawingContainer.isHidden = true
        toolBar.isHidden = true
        doneButton.isHidden = true
        cropOverlay.isHidden = true
        
        switch editMode {
        case .drawing:
            drawingContainer.isHidden = false
            setupDrawingTools()
        case .brightness:
            brightnessContainer.isHidden = false
            toolBar.isHidden = false
        case .filter:
            filterContainer.isHidden = false
            toolBar.isHidden = false
        case .crop:
            cropContainer.isHidden = false
            cropOverlay.isHidden = false
            doneButton.isHidden = false
        case .none:
            toolBar.isHidden = false
        }
    }
    
    // MARK: - お絵描きツール設置
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
        
        drawingContainer.addSubview(penButton)
        drawingContainer.addSubview(eraserButton)
        drawingContainer.addSubview(undoButton)
        
        // 描画キャンバス追加
        let canvas = DrawingCanvas(frame: drawingContainer.bounds)
        canvas.currentTool = currentTool
        canvas.backgroundColor = .clear
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        drawingContainer.addSubview(canvas)
    }
    
    // ペン・消しゴム切り替え時に反映
    @objc func selectPen() {
        currentTool = .pen
        drawingContainer.subviews.compactMap { $0 as? DrawingCanvas }.forEach { $0.currentTool = .pen }
    }

    @objc func selectEraser() {
        currentTool = .eraser
        drawingContainer.subviews.compactMap { $0 as? DrawingCanvas }.forEach { $0.currentTool = .eraser }
    }

    @objc func undoAction() {
        drawingContainer.subviews.compactMap { $0 as? DrawingCanvas }.forEach { $0.undo() }
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
        doneButton.addTarget(self, action: #selector(applyCrop), for: .touchUpInside)
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
        
        let drawingBtn = UIButton(type: .system)
        drawingBtn.setTitle("お絵描き", for: .normal)
        drawingBtn.tintColor = .white
        drawingBtn.addTarget(self, action: #selector(selectDrawing), for: .touchUpInside)
        
        let filterBtn = UIButton(type: .system)
        filterBtn.setTitle("フィルター", for: .normal)
        filterBtn.tintColor = .white
        filterBtn.addTarget(self, action: #selector(selectFilter), for: .touchUpInside)
        
        let cropBtn = UIButton(type: .system)
        cropBtn.setTitle("トリミング", for: .normal)
        cropBtn.tintColor = .white
        cropBtn.addTarget(self, action: #selector(selectCrop), for: .touchUpInside)
        
        let brightnessBtn = UIButton(type: .system)
        brightnessBtn.setTitle("光度", for: .normal)
        brightnessBtn.tintColor = .white
        brightnessBtn.addTarget(self, action: #selector(selectBrightness), for: .touchUpInside)
        
        toolBar.addArrangedSubview(drawingBtn)
        toolBar.addArrangedSubview(filterBtn)
        toolBar.addArrangedSubview(cropBtn)
        toolBar.addArrangedSubview(brightnessBtn)
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
    
    @objc func selectDrawing() { editMode = .drawing; updateTitle("お絵描き") }
    @objc func selectFilter() { editMode = .filter; updateTitle("フィルター") }
    @objc func selectCrop() { editMode = .crop; updateTitle("トリミング") }
    @objc func selectBrightness() { editMode = .brightness; updateTitle("光度") }
    
    func updateTitle(_ text: String) { navTitleLabel.text = text }
    
    @objc func handleCropPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: imageView)
        if let view = sender.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            sender.setTranslation(.zero, in: imageView)
        }
    }
    
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
            cropOverlay.frame = CGRect(x: 20, y: 20, width: 160, height: 160)
        }
    }
}
