//
//  TimeLineTableViewController.swift
//  TwitterApp
//
//  Created by 横山卓也 on 2015/09/12.
//  Copyright (c) 2015年 yokoyama. All rights reserved.
//

import UIKit
import Social
import Accounts

class TimeLineTableViewController: UITableViewController {
    
    var dataArray:[TimeLineUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //クロージャを使うとたまにコンパイルエラーが発生するので、原因不明のコンパイルエラーが起こったらここをチェックする
        AccountDataLogic().checkloginTwitter { (timeLineUsers) -> Void in
            self.dataArray = timeLineUsers
            
            //指定したスレッド(メインキュー)に非同期通信でのデータを受け取った場合、指定したメソッドを実行する
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            
            })
        }
        println("処理の順番②")
    }

    //テーブルの件数を登録
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    //テーブルの内容を代入
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //セルを内部的にリサイクルしているのでこちらが必須になります。
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        
        println("表示したいIndex : \(indexPath.row)")
        
        let timeLineOneUser = self.dataArray[indexPath.row]
        cell.textLabel?.text = timeLineOneUser.text
        var urlString = timeLineOneUser.image
        cell.imageView?.sd_setImageWithURL(NSURL(string: urlString)
        , placeholderImage: UIImage(named: "placeholder"))
        return cell
    }
    
    @IBAction func tapTweetButton(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            //CancelもしくはPostを押した際に呼ばれ、投稿画面を閉じる処理を行っています。
            vc.completionHandler = {(result:SLComposeViewControllerResult) -> () in
                vc.dismissViewControllerAnimated(true, completion:nil)
            }
            
            ////投稿画面の初期値設定
            //vc.setInitialText("初期テキストを設定できます。")
            //vc.addURL(NSURL(string:"シェアURLを設定できます。"))
            self.presentViewController(vc, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "エラー", message: "Twitterアカウントが登録されていません。設定アプリを開きますか？", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "はい", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                if let URL = NSURL(string: UIApplicationOpenSettingsURLString){
                    UIApplication.sharedApplication().openURL(URL)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "いいえ", style: UIAlertActionStyle.Default, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
}
