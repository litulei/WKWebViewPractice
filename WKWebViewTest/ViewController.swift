//
//  ViewController.swift
//  WKWebViewTest
//
//  Created by bitu on 2019/4/4.
//  Copyright © 2019 bitu. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var barBackgroundView: UIView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    @IBOutlet weak var stopReloadButton: UIBarButtonItem!
    
    var webView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        navigationItem.titleView = barBackgroundView
        barBackgroundView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        view.insertSubview(webView, belowSubview: progressView)
        webView.navigationDelegate = self
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let top = webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let leading = webView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailing = webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let bottom = webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44)
        view.addConstraints([top, leading, trailing, bottom])
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        progressView.setProgress(0.0, animated: false)
        
        inputTextField.text = "https://www.baidu.com"
        if #available(iOS 11, *) {
            let inputStr = inputTextField.text
            let url = URL(string: inputStr!)
            let request = URLRequest(url: url!)
            webView.load(request)
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loading" {
            UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
            stopReloadButton.image = webView.isLoading ? UIImage(named: "icon_stop") : UIImage(named: "icon_refresh")
        } else if keyPath == "estimatedProgress" {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        barBackgroundView.frame = CGRect(x: 0, y: 0, width: size.width, height: 30)
    }
    
    @objc func cancel() {
        print("cancel.....")
        inputTextField.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
        barBackgroundView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
    
    }
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    @IBAction func goForward(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    @IBAction func stopReload(_ sender: UIBarButtonItem) {
        if webView.isLoading {
            webView.stopLoading()
        } else {
            let request = URLRequest(url: webView.url!)
            webView.load(request)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
        barBackgroundView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        webView.load(URLRequest(url: URL(string: inputTextField.text!)!))
        
        return false
    }
    
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("Request \(navigationAction.request)")
//        decisionHandler(.allow)
        if navigationAction.navigationType == .linkActivated && !(navigationAction.request.url?.host?.lowercased().hasPrefix("www.baidu.com"))! {
            UIApplication.shared.open(navigationAction.request.url!, options: [:]) { (_) in
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
//    private func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        // 判断服务器采用的验证方法
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
//            if challenge.previousFailureCount == 0 {
//                // 如果没有错误的情况下 创建一个凭证，并使用证书
//                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
//                completionHandler(.useCredential, credential)
//            } else {
//                // 验证失败，取消本次验证
//                completionHandler(.cancelAuthenticationChallenge, nil)
//            }
//        } else {
//            completionHandler(.cancelAuthenticationChallenge, nil)
//        }
//    }
}

