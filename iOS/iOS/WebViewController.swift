//
//  WebViewController.swift
//  AR_APP
//
//  Created by bei on 2020/07/29.
//  Copyright © 2020 bei. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler{

        var webview: WKWebView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            //javascript呼び出しを可能にするWKUserContentControllerクラスの生成
            let userController = WKUserContentController()
            userController.add(self, name: "callbackHandler")
            
            //WKWebViewの設定を行う為のWKWebViewConfigurationクラスの生成
            let webConfiguration = WKWebViewConfiguration()
            webConfiguration.userContentController = userController
            
            //WKWebView生成
            webview = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), configuration: webConfiguration)
            webview.navigationDelegate = self
            webview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webview)
            
            //表示するアドレス設定
            let request = URLRequest(url: URL(string: "https://yuuki0203.github.io/IronMan-sample/login.html")!)
            self.webview.load(request)
        }

        //WKScriptMessageHandlerプロトコル
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if (message.name == "callbackHandler") {
                print(message.body)
                //QRコード読み取り画面への遷移
                self.performSegue(withIdentifier: "toFirst", sender: nil)
            }
        }
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    }
