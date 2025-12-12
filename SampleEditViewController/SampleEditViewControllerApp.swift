//
//  SampleEditViewControllerApp.swift
//  SampleEditViewController
//
//  Created by Yuki Sasaki on 2025/12/12.
//

import SwiftUI

@main
struct SampleEditViewControllerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
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

