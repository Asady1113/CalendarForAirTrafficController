//
//  AppApp.swift
//  App
//
//  Created by 浅田智哉 on 2026/02/08.
//

import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct AppApp: App {
    let modelContainer: ModelContainer
    let diContainer: DIContainer

    init() {
        do {
            let schema = Schema([
                CrewModel.self,
                CellModel.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            diContainer = DIContainer(modelContext: modelContainer.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diContainer)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .modelContainer(modelContainer)
    }
}
