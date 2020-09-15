//
//  ViewController.swift
//  MyDessert
//
//  Created by 多田秀人 on 2020/09/15.
//  Copyright © 2020 多田秀人. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchText.delegate = self
        searchText.placeholder = "お菓子の名前を入力してください"
        tableView.dataSource = self
        tableView.delegate = self
    }


    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var dessertList : [(name:String, maker:String, link:URL, image:URL)] = []
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if let searchWord = searchBar.text {
            print(searchWord)
            searchDessert(keyword: searchWord)
        }
    }
    
    struct ItemJson: Codable {
        let name: String?
        let maker: String?
        let url: URL?
        let image: URL?
    }
    
    struct ResultJson: Codable {
        let item: [ItemJson]?
    }
    
    func searchDessert(keyword : String) {
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let req_url = URL(string:
            "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
                return
        }
        print(req_url)
        
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(ResultJson.self, from: data!)
                
//                print(json)
                
                if let items = json.item {
                    self.dessertList.removeAll()
                    for item in items {
                        if let name = item.name, let maker = item.maker, let link = item.url, let image = item.image {
                            let dessert = (name, maker, link, image)
                            self.dessertList.append(dessert)
                        }
                    }
                    
                    self.tableView.reloadData()
                    if let dessertdbg = self.dessertList.first {
                        print("---------------------------")
                        print("dessertList[0] = \(dessertdbg)")
                    }
                }

            } catch {
                print("エラーが出ました")
            }
        })
        task.resume()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return dessertList.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dessertCell", for: indexPath)
        cell.textLabel?.text = dessertList[indexPath.row].name
        if let imageData = try? Data(contentsOf: dessertList[indexPath.row].image) {
            cell.imageView?.image = UIImage(data: imageData)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let safariViewController = SFSafariViewController(url: dessertList[indexPath.row].link)
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
}

