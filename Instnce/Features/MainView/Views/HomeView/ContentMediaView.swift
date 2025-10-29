//
//  ContentMediaView.swift
//  Instnce
//
//  Created by Wafi Choudhury on 10/28/25.
//
import SwiftUI
import AVKit
import YouTubePlayerKit
import WebKit
struct ContentMediaView: View {
    let urlString: String
    let thumbnailUrl: String?
    let videoName: String?
    var height: CGFloat = 180

    var body: some View {
        let player = YouTubePlayer(source: .video(id: urlString))
        
        VStack {
            if let videoName = videoName,
               let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                // Local bundled MP4
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
            } else if let direct = directVideoURL(urlString) {
                // Direct video URL (mp4/mov/hls)
                VideoPlayer(player: AVPlayer(url: direct))
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
            } else if isYouTube(urlString) {
                // Native YouTube player (YouTubePlayerKit)
                YouTubePlayerView(player)
                    .frame(height: max(height, 220))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
            } else if isTikTok(urlString) || isTwitter(urlString) || isInstagram(urlString) {
                // Web embed for platforms
                WebView(url: URL(string: urlString))
                    .frame(height: max(height, 220))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
            } else {
                // Fallback image
                AsyncImage(url: URL(string: thumbnailUrl ?? "")) { img in
                    img.resizable()
                        .scaledToFill()
                        .frame(height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray5))
                        .frame(height: height)
                        .padding(.horizontal)
                }
            }
        }
    }

    private func directVideoURL(_ urlStr: String) -> URL? {
        guard let url = URL(string: urlStr.lowercased()) else { return nil }
        if urlStr.hasSuffix(".mp4") || urlStr.hasSuffix(".mov") || urlStr.contains("/stream/") { return url }
        return nil
    }

    private func isYouTube(_ url: String) -> Bool { url.contains("youtube.com/") || url.contains("youtu.be/") }
    private func isTikTok(_ url: String) -> Bool { url.contains("tiktok.com/") }
    private func isTwitter(_ url: String) -> Bool { url.contains("twitter.com/") || url.contains("x.com/") }
    private func isInstagram(_ url: String) -> Bool { url.contains("instagram.com/") }
}

private struct WebView: UIViewRepresentable {
    let url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let view = WKWebView(frame: .zero, configuration: config)
        view.scrollView.isScrollEnabled = false
        view.isOpaque = false
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = url else { return }
        // Basic embed: load the URL directly. For YouTube/TikTok you can later switch to their oEmbed or embed URL formats.
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
