//
//  ViewController.swift
//  GSPANN
//
//  Created by Paras Lamba on 21/04/18.
//  Copyright © 2018 Paras. All rights reserved.
//

import UIKit
import FilesProvider

class ViewController: UIViewController {
    
    var topTenFilesDataSource:[FileObject] = []
    var frequentFilesExtDataSource:[(key:String,value:Int)] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView_files: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView_files.delegate = self
        tableView_files.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        tableView_files.isHidden = true
    }
    
    @IBOutlet weak var btnScan: UIButton!
    
    @IBAction func btnScanClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        topTenFilesDataSource.removeAll()
        frequentFilesExtDataSource.removeAll()
        showTopTenFilesAndFrequentFileExtension()
    }
    
    func showTopTenFilesAndFrequentFileExtension(){
        DispatchQueue.global().async {
            let documentsProvider = CloudFileProvider(containerId: nil)
            documentsProvider?.contentsOfDirectory(path: "/", completionHandler: {
                contents, error in
                let fileSorter = FileObjectSorting.sizeDesceding
                let sortedContent = fileSorter.sort(contents)
                
                for file in sortedContent.prefix(10) {
                    print("Name: \(file.name)")
                    print("Size: \(file.size)")
                    print("Creation Date: \(String(describing: file.creationDate))")
                    print("Modification Date: \(String(describing: file.modifiedDate))")
                    self.topTenFilesDataSource.append(file)
                }
                
                
                var freqFilesDict = [String:Int]()
                for file in contents{
                    if(freqFilesDict.keys.contains(file.url.pathExtension)){
                        freqFilesDict[file.url.pathExtension]! += 1
                    }
                    else{
                        freqFilesDict[file.url.pathExtension] = 1
                    }
                }
                self.frequentFilesExtDataSource = Array(freqFilesDict.sorted(by: { (arg0, arg1) -> Bool in
                    return arg1.value < arg0.value
                }).prefix(5))
                
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView_files.reloadData()
                    self.tableView_files.isHidden = false
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0{
            return topTenFilesDataSource.count
        }
        else{
            return frequentFilesExtDataSource.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            var noDataCell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if noDataCell == nil {
                noDataCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            }
        //let dataList = DataSourceToDisplay[indexPath.section] as AnyObject
        
        if indexPath.section == 0 {
            let dataFile = self.topTenFilesDataSource[indexPath.row]
            noDataCell?.textLabel?.text = "Name: \(dataFile.name)"
            noDataCell?.detailTextLabel?.text = "Size: \(dataFile.size)"
        }
        else
        {
            let dataExt = self.frequentFilesExtDataSource[indexPath.row]
            noDataCell?.textLabel?.text = "Name: \(dataExt.key)"
            noDataCell?.detailTextLabel?.text = "Frequency: \(dataExt.value)"
        }
            return noDataCell!
        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let screenSize: CGRect = UIScreen.main.bounds
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 30))
        let lblShowSectonTitle = UILabel(frame: CGRect(x: 10, y: 0, width: customView.bounds.size.width/1.8, height: 30))
        let labelTextColor = UIColor ( red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1.0 )
        lblShowSectonTitle.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)!
        lblShowSectonTitle.textColor = labelTextColor
        
        customView.backgroundColor = UIColor.lightGray
        if section == 0 {
            lblShowSectonTitle.text = "Top 10 Big Size Files"
        }
        else
        {
            lblShowSectonTitle.text = "Frequently occuring Extensions"
        }
        
        customView.addSubview(lblShowSectonTitle);
        return customView;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


