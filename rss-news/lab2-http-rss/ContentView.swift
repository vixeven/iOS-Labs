//
//  ContentView.swift
//  lab2-http-rss
//
//  Created by Victor Șaptefrați on 13.01.2023.
//

import SwiftUI
import AEXML
import WebKit

struct Article: Identifiable {
    let id: String
    let title: String
    let link: String
    let summary: String
}

struct ContentView: View {
    var body: some View {
        TabView {
            NewsTabView(tabName: "Agora", url: "https://agora.md/rss/news.xml")
                .tabItem {
                    Image(systemName: "globe")
                    Text("Agora")
                }
            NewsTabView(tabName: "Digi24", url: "https://www.digi24.ro/rss")
                .tabItem {
                    Image(systemName: "globe")
                    Text("Digi24")
                }
        }
    }
}

struct WebView: View {
    let url: String
    var body: some View {
        WebViewRepresentable(url: url)
    }
}

struct CardView: View {
    let article: Article
    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.headline)
            Text(article.summary)
                .font(.subheadline)
        }
        .padding()
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: self.url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

struct NewsTabView: View {
    @State private var articles: [Article] = []
    var tabName: String
    var url: String
    
    var body: some View {
        NavigationView {
            List(articles) { article in
                NavigationLink(destination: WebView(url: article.link)) {
                    CardView(article: article)
                }
            }
            .navigationBarTitle(tabName)
            .onAppear(perform: fetchXML)
        }
        
    }
    func fetchXML() {
        guard let url = URL(string: self.url) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            let xml = String(decoding: data, as: UTF8.self)
            self.parseXML(xml)
        }
        .resume()
    }
    
    func parseXML(_ xml: String) {
        do {
            let xmlDoc = try AEXMLDocument(xml: xml)
            guard let channel = xmlDoc.root["channel"].first, let items = channel["item"].all else { return }
            for item in items {
                let title = item["title"].value
                let link = item["link"].value ?? "https://google.ro"
                let description = item["description"].value ?? "Lorem ipsum dolor sit amet."
                let pubDate = item["pubDate"].value
                
                articles.append(Article(id: pubDate!, title: title!, link: link, summary: description))
            }
            DispatchQueue.main.async {
                self.articles = self.articles
            }
        } catch {
            print(error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
