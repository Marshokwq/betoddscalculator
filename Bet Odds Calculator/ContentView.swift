import SwiftUI

// ↓ true — WebView, false — app
private let showWebView: Bool = false

// ↓ URL для WebView
private let webViewURL: String = "https://google.com"

struct ContentView: View {
    var body: some View {
        if showWebView, let url = URL(string: webViewURL) {
            WebView(url: url)
                .ignoresSafeArea()
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}
