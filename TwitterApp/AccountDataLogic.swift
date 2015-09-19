//
//  AccountDataLogic.swift
//  TwitterApp
//
//  Created by 今村翔一 on 2015/09/14.
//  Copyright (c) 2015年 yokoyama. All rights reserved.
//

import UIKit
import Social
import Accounts

class AccountDataLogic: UITableViewController {
    
    var twitterAccount:ACAccount?
    
    //Twitterのアクセストークンを取得
    func checkloginTwitter(callback :([TimeLineUser]) -> Void){
        //Twitterが登録されていないケース
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            return
        }
        
        let store = ACAccountStore();
        let type = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccountsWithType(type, options: nil) { (granted, error) -> Void in
            
            if error != nil{
                return;
            }
            
            if granted == false{
                //アカウントは登録されているが認証が拒否されたケース
                return;
            }
            
            let accounts = store.accountsWithAccountType(type);
            
            if accounts.count == 0{
                return;
            }
            
            if let account = accounts[0] as? ACAccount{
                //アカウントをメモリに保持
                self.twitterAccount = account
                println("処理の順番③")
                self.downloadTwitterTimeLine(callback)
            }
        }
        println("処理の順番①")
    }
    
    //Twitterのタイムラインを取得する
    func downloadTwitterTimeLine(callback :([TimeLineUser]) -> Void){
        
        //自分の投稿一覧は「user_timeline.json」で取得可能
        var timeLineUsers:[TimeLineUser] = []
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: URL, parameters: nil)
        request.account = twitterAccount
        request.performRequestWithHandler { (responseData, responseURL, error) -> Void in
            if error != nil{
                return;
            }
            if let res = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as? [NSDictionary]{
                for entry in res{
                    if let user = entry["user"] as? NSDictionary, let name = user["name"] as? String,let text = entry["text"] as? String, let image = user["profile_image_url"] as? String {
                        var timeLineUser = TimeLineUser(name: name, text: text, image: image)
                        timeLineUsers.append(timeLineUser)
                        //println("=====================================")
                        //println(entry)
                    }
                }
                callback(timeLineUsers)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    //println(dataArray)
                    println("処理の順番⑤")
                })
            }
        }
        println("処理の順番④")
    }
}
