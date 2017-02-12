
//
//  FlicksCollectController.swift
//  Flick
//
//  Created by Cong Tam Quang Hoang on 06/02/17.
//  Copyright © 2017 Cong Tam Quang Hoang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class FlicksCollectController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {

    
    @IBAction func Tab(_ sender: Any) {
        self.goingToTableView = true
        
        performSegue(withIdentifier: "TabSegue", sender: nil)
        print("pushed")
        
    }
    
    var goingToTableView: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    var movies:[NSDictionary]?
    var endpoint: String = ""
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "FlicksCollectionCell", for: indexPath) as! FlicksCollectionCell
        
        let movie = movies![indexPath.row]
        //     let title = movie["title"] as! String
        //   let overview = movie["overview"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.FilmsView.setImageWith(imageUrl as! URL)
        }
        
        print("row \(indexPath.row)")
        return cell
    }
    func collectionView(_ collectionView:
        UICollectionView,numberOfItemsInSection section: Int) -> Int{
        if let movies = movies {
            return movies.count
        }else{
            return 0
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        
        // Configure session so that completion handler is executed on main UI thread
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            self.collectionView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.collectionView.reloadData()
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
        task.resume()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.black
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation
 
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if goingToTableView{
            let dest = segue.destination as! FlicksTabsController
            dest.endpoint = self.endpoint
            self.goingToTableView = false
            return
        }
        let cell = sender as! UICollectionViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.red
        cell.selectedBackgroundView = backgroundView
        let indexpath = collectionView.indexPath(for: cell)
        let movie = movies![indexpath!.row]
        
        let filmsViewController = segue.destination as! FilmsViewController
        filmsViewController.movie = movie
        
        //segue.destination as! FlicksTabsController
        //print(segue.destination)
        
    }


}
