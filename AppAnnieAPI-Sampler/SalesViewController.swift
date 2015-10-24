//
//  SalesViewController.swift
//  AppAnnieAPI-Sampler
//
//  Created by Masuhara on 2015/10/22.
//  Copyright © 2015年 masuhara. All rights reserved.
//

import UIKit

class SalesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let token = "Bearer 48c6d5c2dda1a4ea36849a744fe581256b45fc5c"
    var userInfo: NSDictionary!
    var appInfo = [AnyObject]()
    var salesInfo = [AnyObject]()
    
    @IBOutlet var salesTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.salesTable.dataSource = self
        self.salesTable.delegate = self
        
        self.loadSales()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return appInfo.count
        return self.salesInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
        
        if appInfo.count > 0 {
            cell.textLabel!.text = self.appInfo[indexPath.row]["product_name"] as? String
            let download = self.salesInfo[indexPath.row].valueForKeyPath("units.product.downloads") as! Int
            cell.detailTextLabel!.text = String(format: "%d DL", download)
        }
        
        return cell
    }
    
    func loadSales() {
        SVProgressHUD.show()

        let account_id = self.userInfo["accounts"]![0]["account_id"] as! Int
        let start_date = self.userInfo["accounts"]![0]["first_sales_date"] as! String
        let end_date = self.userInfo["accounts"]![0]["last_sales_date"] as! String

        let URL_String = String(format: "https://api.appannie.com/v1.2/accounts/%d/sales?break_down=product&start_date=%@&end_date=%@", account_id, start_date, end_date)
        let rasterRequest = NSMutableURLRequest(URL: NSURL(string: URL_String)!)
        rasterRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let operation = AFHTTPRequestOperation(request: rasterRequest)
        operation.responseSerializer = AFJSONResponseSerializer()
        operation.setCompletionBlockWithSuccess({ (requestOperation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            
            self.salesInfo = responseObject["sales_list"] as! [NSDictionary]
            self.getAppName(self.salesInfo)
            
            }, failure: {(requestOperation: AFHTTPRequestOperation!, error: NSError!) in
                print(error)
                SVProgressHUD.dismiss()
        })
        operation.start()
    }
    
    // TODO: アプリ名とダウンロード数を別で取得しているため、たまにアプリ名とDL数の表示がズレるのを直す
    func getAppName(apps: [AnyObject]) {
        for app in apps {
            let URL_String = String(format:"https://api.appannie.com/v1.2/apps/ios/app/%@/details", app["product_id"] as! String)
            let rasterRequest = NSMutableURLRequest(URL: NSURL(string: URL_String)!)
            rasterRequest.setValue(token, forHTTPHeaderField: "Authorization")
            let operation = AFHTTPRequestOperation(request: rasterRequest)
            operation.responseSerializer = AFJSONResponseSerializer()
            operation.setCompletionBlockWithSuccess({ (requestOperation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                
                self.appInfo.append(responseObject["product"] as! NSDictionary)
                if self.appInfo.count == self.salesInfo.count {
                    self.salesTable.reloadData()
                    SVProgressHUD.dismiss()
                }
                }, failure: {(requestOperation: AFHTTPRequestOperation!, error: NSError!) in
                    print(error)
                    SVProgressHUD.dismiss()
            })
            operation.start()
        }
    }
}
