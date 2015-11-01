//
//  ViewController.swift
//  AppAnnieAPI-Sampler
//
//  Created by Masuhara on 2015/10/22.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    var userInfo: NSDictionary!
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.webView.scalesPageToFit = true
        self.loadPage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func authentication() {
        SVProgressHUD.show()
        
        let URL_String = "https://api.appannie.com/v1.2/accounts"
        let token = "Bearer ここに自分のAPI Key"
        let rasterRequest = NSMutableURLRequest(URL: NSURL(string: URL_String)!)
        rasterRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let operation = AFHTTPRequestOperation(request: rasterRequest)
        operation.responseSerializer = AFJSONResponseSerializer()
        operation.setCompletionBlockWithSuccess( { (requestOperation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            self.userInfo = responseObject as! NSDictionary
            self.showAlert()
            SVProgressHUD.dismiss()
            }, failure: { (requestOperation: AFHTTPRequestOperation!, error: NSError!) in
                print(error)
                SVProgressHUD.dismiss()
        })
        operation.start()
    }
    
    func loadPage() {
        let authPage = "https://www.appannie.com/account/api/key/"
        let url: NSURL = NSURL(string: authPage)!
        let urlRequest: NSURLRequest = NSURLRequest(URL: url)
        self.webView.loadRequest(urlRequest)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showAlert() {
        let alertView = UIAlertView(title: "認証完了", message: "AppAnnieの認証が完了しました。", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "OK")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.performSegueWithIdentifier("toSales", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let salesViewController = segue.destinationViewController as! SalesViewController
        salesViewController.userInfo = self.userInfo
    }
}

