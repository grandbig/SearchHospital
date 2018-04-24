//
//  ViewController+Alert.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/04/24.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

internal enum AlertError: Error {
    case cancel
}

internal enum TappedActionSheetNumber {
    case first
    case second
}

extension UIViewController {

    /// OKボタンのみのアラート表示
    ///
    /// - Parameters:
    ///   - title: アラートのタイトル
    ///   - message: アラートのメッセージ
    /// - Returns: Promiseオブジェクト
    internal func showAlert(title: String = R.string.common.confirmation(), message: String) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: R.string.common.ok(), style: UIAlertActionStyle.default) { _ in
            resolver.fulfill(Void())
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
        
        return promise
    }
    
    /// OK/キャンセルボタンつきアラート表示
    ///
    /// - Parameters:
    ///   - title: アラートのタイトル
    ///   - message: アラートのメッセージ
    /// - Returns: Promiseオブジェクト
    internal func showConfirm(title: String, message: String) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: R.string.common.ok(), style: UIAlertActionStyle.default) { _ in
            resolver.fulfill(Void())
        }
        let cancelAction = UIAlertAction.init(title: R.string.common.cancel(), style: UIAlertActionStyle.cancel) { _ in
            resolver.reject(AlertError.cancel)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        return promise
    }
    
    /// 2つの選択肢を持つアクションシートの表示
    ///
    /// - Parameters:
    ///   - message: アクションシートのメッセージ
    ///   - firstActionTitle: 1つ目の選択肢
    ///   - secondActionTitle: 2つ目の選択肢
    /// - Returns: Promiseオブジェクト
    internal func showActionSheet(message: String,
                                  firstActionTitle: String,
                                  secondActionTitle: String) -> Promise<TappedActionSheetNumber> {
        let (promise, resolver) = Promise<TappedActionSheetNumber>.pending()
        
        let alert = UIAlertController.init(title: R.string.common.confirmation(),
                                           message: message,
                                           preferredStyle: UIAlertControllerStyle.actionSheet)
        let firstAction = UIAlertAction.init(title: firstActionTitle, style: UIAlertActionStyle.default) { _ in
            resolver.fulfill(TappedActionSheetNumber.first)
        }
        let secondAction = UIAlertAction.init(title: secondActionTitle, style: UIAlertActionStyle.default) { _ in
            resolver.fulfill(TappedActionSheetNumber.second)
        }
        let cancelAction = UIAlertAction.init(title: R.string.common.cancel(), style: UIAlertActionStyle.cancel) { _ in
        }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        return promise
    }
}
