//
//  ViewController.swift
//  SignalR
//
//  Created by Daniel on 2019/5/8.
//  Copyright © 2019 Daniel. All rights reserved.
//

import UIKit
import SwiftSignalRClient

class ViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var textView: UITextView!
    
    private let serverUrl = "http://www.trible.io/signalr"
    private var hubConnection: HubConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureHubConnection()
    }
    
    private func configureHubConnection() {
        self.hubConnection = HubConnectionBuilder(url: URL(string: serverUrl)!).withLogging(minLogLevel: .debug).build()
        
        self.hubConnection?.delegate = self
        
        //收到新訊息
        //callback中的args就是在傳送訊息時的arguments
        self.hubConnection?.on(method: "Send", callback: { (args, typeConverter) in
            do {
//                let name = try typeConverter.convertFromWireType(obj: args[0], targetType: String.self)
//                let message = try typeConverter.convertFromWireType(obj: args[1], targetType: String.self)
                print("=== 收到新訊息: \(args)")
                if let message = try typeConverter.convertFromWireType(obj: args[0], targetType: String.self), let textViewText = self.textView.text {
                    self.textView.text = "\(textViewText)\n\(message)"
                }
            } catch {
                print(error)
            }
        })
        self.hubConnection?.start()
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.hasText {
            self.hubConnection?.invoke(method: "Send", arguments: [textField.text], invocationDidComplete: { (error) in
                if error == nil {
                    print("=== 傳送成功")
                } else {
                    print("=== 傳送失敗: \(error?.localizedDescription ?? "未知原因")")
                }
            })
            textField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: HubConnectionDelegate {
    func connectionDidOpen(hubConnection: HubConnection!) {
        print("=== connectionDidOpen")
    }
    
    func connectionDidFailToOpen(error: Error) {
        if error is SignalRError {
            let e = error as! SignalRError
            print("=== connectionDidFailToOpen, error: \(e.self)")
        } else {
            print("=== connectionDidFailToOpen, error: \(error.localizedDescription)")
        }
    }
    
    func connectionDidClose(error: Error?) {
        if let e = error {
            if e is SignalRError {
                let se = e as! SignalRError
                print("=== connectionDidClose, error: \(se.self)")
            } else {
                print("=== connectionDidClose, error: \(e.localizedDescription)")
            }
        } else {
            print("=== connectionDidClose")
        }
    }
}

