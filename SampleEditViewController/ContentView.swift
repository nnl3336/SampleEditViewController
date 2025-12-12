//
//  ContentView.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import SwiftUI
import CoreData

import UIKit

enum EditMode {
    case none
    case brightness
    case filter
    case crop
}

class SampleEditViewController: UIViewController {

    private let navBar = UINavigationBar()
    private let editNavBar = UIView()
    private let toolBar = UIToolbar()
    
    private var editMode: EditMode = .none {
        didSet { updateUIForMode() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setupBars()
    }
    
    private func setupBars() {
        // 通常ナビバー
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)
        let normalItem = UINavigationItem(title: "通常モード")
        navBar.items = [normalItem]
        navBar.barTintColor = .black
        navBar.tintColor = .white
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 編集ナビバー
        editNavBar.translatesAutoresizingMaskIntoConstraints = false
        editNavBar.backgroundColor = .black
        editNavBar.isHidden = true
        view.addSubview(editNavBar)
        NSLayoutConstraint.activate([
            editNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            editNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editNavBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        let editLabel = UILabel()
        editLabel.text = "編集中"
        editLabel.textColor = .white
        editLabel.translatesAutoresizingMaskIntoConstraints = false
        editNavBar.addSubview(editLabel)
        NSLayoutConstraint.activate([
            editLabel.centerXAnchor.constraint(equalTo: editNavBar.centerXAnchor),
            editLabel.centerYAnchor.constraint(equalTo: editNavBar.centerYAnchor)
        ])
        
        // 下ツールバー
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)
        NSLayoutConstraint.activate([
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let brightnessButton = UIBarButtonItem(title: "明るさ", style: .plain, target: self, action: #selector(selectBrightness))
        let filterButton = UIBarButtonItem(title: "フィルター", style: .plain, target: self, action: #selector(selectFilter))
        let cropButton = UIBarButtonItem(title: "トリミング", style: .plain, target: self, action: #selector(selectCrop))
        let normalButton = UIBarButtonItem(title: "通常", style: .plain, target: self, action: #selector(selectNormal))
        
        toolBar.setItems([brightnessButton, filterButton, cropButton, normalButton], animated: false)
    }
    
    private func updateUIForMode() {
        switch editMode {
        case .none:
            navBar.isHidden = false
            editNavBar.isHidden = true
        case .brightness, .filter, .crop:
            navBar.isHidden = true
            editNavBar.isHidden = false
        }
        
        // ツールバー背景色変更（デバッグ用）
        switch editMode {
        case .none:
            toolBar.barTintColor = .black
        case .brightness:
            toolBar.barTintColor = .systemYellow
        case .filter:
            toolBar.barTintColor = .systemBlue
        case .crop:
            toolBar.barTintColor = .systemGreen
        }
    }
    
    @objc private func selectBrightness() { editMode = .brightness }
    @objc private func selectFilter() { editMode = .filter }
    @objc private func selectCrop() { editMode = .crop }
    @objc private func selectNormal() { editMode = .none }
}


// MARK: - ContentView
struct ContentView: View {
    var body: some View {
        //NavigationView {
            ListVCWrapper()
                //.navigationTitle("Detail")
                /*.toolbar {
                    // 左側にボタン
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { print("＋ボタン tapped") }) {
                            Image(systemName: "plus")
                        }
                    }
                    
                    // 右側にボタン
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { print("完了 tapped") }) {
                            Text("Done")
                        }
                    }
                }*/
        //}
    }
}




struct ListVCWrapper: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext

    func makeUIViewController(context: Context) -> UINavigationController {
        let notesVC = SampleEditViewController()
        //notesVC.viewContext = viewContext  // ← 修正
        let nav = UINavigationController(rootViewController: notesVC)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // 必要に応じて状態を更新
    }
}

