//
//  SearchViewController.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 08/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//
import UIKit

class SearchViewController: UIViewController {
    
    var array : [Constituency] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredLocations = [Constituency]()
    var constituency = Constituency()
    var selected = 0
    
    @IBOutlet weak var searchTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
        searchTable.backgroundColor = .clear
        searchTable.delegate = self
        searchTable.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        definesPresentationContext = true
        let searchView = UIView()
        self.view.addSubview(searchTable)
        searchView.addSubview(searchController.searchBar)
        searchController.searchBar.searchBarStyle = .minimal
        self.searchTable.tableHeaderView = searchView
        self.searchTable.tableHeaderView?.frame.size.height = 50
        self.searchTable.separatorStyle = .none
        searchTable.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredLocations = array.filter({( constituency : Constituency) -> Bool in
            return constituency.name!.lowercased().contains(searchText.lowercased())
        })
        self.searchTable.reloadData()
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredLocations.count
        }
        
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
        let const: Constituency
        if isFiltering() {
            const = filteredLocations[indexPath.row]
        } else {
            const = array[indexPath.row]
        }
        cell.resultLabel.text = const.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering(){
            constituency = filteredLocations[indexPath.row]
        }
        else{
            constituency = array[indexPath.row]
        }
        if searchController.isActive == true {
            searchController.dismiss(animated: true, completion: {
                print("✅ Tapped \(self.constituency.name!)")
                //start sockets
                Requests.shared.setupSockets(self.constituency.ac_no!, stream: true)
                
                let dvc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail") as! DetailDistrictViewController
                dvc.fromModal = true
                dvc.constituency = self.constituency
                self.parent?.present(dvc, animated: true, completion: nil)
            })
        }
        else{
            print("✅ Tapped \(constituency.name!)")
            //start sockets
            Requests.shared.setupSockets(self.constituency.ac_no!, stream: true)
            
            let dvc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail") as! DetailDistrictViewController
            dvc.fromModal = true
            dvc.constituency = self.constituency
            self.parent?.present(dvc, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
}

extension SearchViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
}
