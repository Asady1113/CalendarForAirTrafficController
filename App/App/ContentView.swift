//
//  ContentView.swift
//  App
//
//  Created by 浅田智哉 on 2026/02/08.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var diContainer: DIContainer

    var body: some View {
        CrewListView(diContainer: diContainer)
    }
}

#Preview {
    // プレビュー用のモックは省略
    Text("Preview requires DIContainer")
}
