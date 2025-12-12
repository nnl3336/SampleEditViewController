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
}

class SampleEditViewController: UIViewController {

    private let navBar = UINavigationBar()
    private let editNavBar = UIView()
    private let toolBar = UIToolbar()
    private let imageView = UIImageView()
    
    private var brightnessSlider: UISlider!
    
    private var editMode: EditMode = .none {
        didSet { updateUIForMode() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        
        setupImageView()
        setupBars()
        setupBrightnessSlider()
    }
    
    private func setupImageView() {
        imageView.image = UIImage(named: "sampleImage") // プロジェクトに画像を追加
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupBars() {
        // 通常ナビバー
        // 編集バーの修正版
        editNavBar.translatesAutoresizingMaskIntoConstraints = false
        editNavBar.backgroundColor = .black
        editNavBar.isHidden = true
        view.addSubview(editNavBar)

        // safeArea の上ではなく view の top に合わせる
        NSLayoutConstraint.activate([
            editNavBar.topAnchor.constraint(equalTo: view.topAnchor),  // ← safeArea ではなく view.top
            editNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editNavBar.heightAnchor.constraint(equalToConstant: 88)    // ステータスバー分 + ナビバー高さ (44+44)
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
        editLabel.text = "明るさ調整中"
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
        let normalButton = UIBarButtonItem(title: "通常", style: .plain, target: self, action: #selector(selectNormal))
        toolBar.setItems([brightnessButton, UIBarButtonItem.flexibleSpace(), normalButton], animated: false)
    }
    
    private func setupBrightnessSlider() {
        brightnessSlider = UISlider()
        brightnessSlider.minimumValue = -1.0
        brightnessSlider.maximumValue = 1.0
        brightnessSlider.value = 0
        brightnessSlider.tintColor = .systemYellow
        brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        brightnessSlider.addTarget(self, action: #selector(brightnessChanged(_:)), for: .valueChanged)
        view.addSubview(brightnessSlider)
        
        NSLayoutConstraint.activate([
            brightnessSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            brightnessSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            brightnessSlider.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        ])
        
        brightnessSlider.isHidden = true
    }
    
    private func updateUIForMode() {
        switch editMode {
        case .none:
            navBar.isHidden = false
            editNavBar.isHidden = true
            brightnessSlider.isHidden = true
        case .brightness:
            navBar.isHidden = true
            editNavBar.isHidden = false
            brightnessSlider.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc private func selectBrightness() { editMode = .brightness }
    @objc private func selectNormal() { editMode = .none }
    
    @objc private func brightnessChanged(_ sender: UISlider) {
        guard let originalImage = UIImage(named: "sampleImage") else { return }
        imageView.image = applyBrightness(to: originalImage, value: sender.value)
    }
    
    private func applyBrightness(to image: UIImage, value: Float) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: kCIInputBrightnessKey)
        
        let context = CIContext()
        if let output = filter.outputImage,
           let cgOutput = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgOutput)
        }
        return nil
    }
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

