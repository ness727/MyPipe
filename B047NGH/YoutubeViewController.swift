//
//  YoutubeViewController.swift
//  B047NGH
//
//  Created by 소프트웨어컴퓨터 on 2024/05/30.
//

import UIKit
import WebKit

class YoutubeViewController: UIViewController {
    var videoId = ""
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://youtube.com/embed/\(videoId)") else { return }
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
}
