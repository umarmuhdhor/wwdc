import SwiftUI

@main
struct LegendaARApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @State private var showOpeningView = true
    
    var body: some Scene {
        WindowGroup {
//            OpeningView(showOpeningView: $showOpeningView)
            ContentView()
        }
    }
}
