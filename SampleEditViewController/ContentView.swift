//
//  ContentView.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import SwiftUI
import CoreData

import UIKit

class SampleEditViewController
: UIViewController {
    
    enum EditMode {
        case none, drawing, filter, crop, brightness
    }
    
    var editMode: EditMode = .none {
        didSet {
            updateUIForMode()
        }
    }
    
    // MARK: - UI
    let navBar = UIView()
    let navTitleLabel = UILabel()
    let backButton = UIButton(type: .system)
    let doneButton = UIButton(type: .system)
    
    let toolBar = UIStackView()
    let drawingButton = UIButton(type: .system)
    let filterButton = UIButton(type: .system)
    let cropButton = UIButton(type: .system)
    let brightnessButton = UIButton(type: .system)
    
    // モード別コンテンツ
    let drawingView = UIView()
    let filterView = UIView()
    let cropView = UIView()
    let brightnessView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavBar()
        setupToolBar()
        setupModeViews()
        updateUIForMode()
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
            navBar.heightAnchor.constraint(equalToConstant: 88) // ステータスバー+44
        ])
        
        // Back
        backButton.setTitle("戻る", for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 16),
            backButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
        ])
        
        // Done
        doneButton.setTitle("完了", for: .normal)
        doneButton.tintColor = .white
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
        ])
        
        // Title
        navTitleLabel.text = ""
        navTitleLabel.textColor = .white
        navTitleLabel.font = .boldSystemFont(ofSize: 18)
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(navTitleLabel)
        NSLayoutConstraint.activate([
            navTitleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            navTitleLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8)
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
        
        drawingButton.setTitle("お絵描き", for: .normal)
        drawingButton.tintColor = .white
        drawingButton.addTarget(self, action: #selector(selectDrawing), for: .touchUpInside)
        
        filterButton.setTitle("フィルター", for: .normal)
        filterButton.tintColor = .white
        filterButton.addTarget(self, action: #selector(selectFilter), for: .touchUpInside)
        
        cropButton.setTitle("トリミング", for: .normal)
        cropButton.tintColor = .white
        cropButton.addTarget(self, action: #selector(selectCrop), for: .touchUpInside)
        
        brightnessButton.setTitle("光度", for: .normal)
        brightnessButton.tintColor = .white
        brightnessButton.addTarget(self, action: #selector(selectBrightness), for: .touchUpInside)
        
        toolBar.addArrangedSubview(drawingButton)
        toolBar.addArrangedSubview(filterButton)
        toolBar.addArrangedSubview(cropButton)
        toolBar.addArrangedSubview(brightnessButton)
    }
    
    // MARK: - Mode Views
    func setupModeViews() {
        let views = [drawingView, filterView, cropView, brightnessView]
        for v in views {
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: navBar.bottomAnchor),
                v.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                v.bottomAnchor.constraint(equalTo: toolBar.topAnchor)
            ])
            v.isHidden = true
        }
        drawingView.backgroundColor = .systemRed.withAlphaComponent(0.3)
        filterView.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        cropView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        brightnessView.backgroundColor = .systemYellow.withAlphaComponent(0.3)
    }
    
    // MARK: - Actions
    @objc func backTapped() {
        editMode = .none
    }
    
    @objc func doneTapped() {
        editMode = .none
    }
    
    @objc func selectDrawing() { editMode = .drawing }
    @objc func selectFilter() { editMode = .filter }
    @objc func selectCrop() { editMode = .crop }
    @objc func selectBrightness() { editMode = .brightness }
    
    // MARK: - Update UI
    func updateUIForMode() {
        // 全部隠す
        drawingView.isHidden = true
        filterView.isHidden = true
        cropView.isHidden = true
        brightnessView.isHidden = true
        
        switch editMode {
        case .none:
            navTitleLabel.text = ""
            doneButton.isHidden = true
        case .drawing:
            drawingView.isHidden = false
            navTitleLabel.text = "お絵描き"
            doneButton.isHidden = false
        case .filter:
            filterView.isHidden = false
            navTitleLabel.text = "フィルター"
            doneButton.isHidden = false
        case .crop:
            cropView.isHidden = false
            navTitleLabel.text = "トリミング"
            doneButton.isHidden = false
        case .brightness:
            brightnessView.isHidden = false
            navTitleLabel.text = "光度"
            doneButton.isHidden = false
        }
    }
}

