//
//  StationSearchViewController.swift
//  ElectionEye
//
//  Created by Aritro Paul on 09/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit

var tappedStation: PollStation?

class StationSearchViewController: UIViewController {

    var array : [PollStation] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredLocations = [PollStation]()
    var selected = 0
    var poll = PollStation()
    
    @IBOutlet weak var searchTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.searchTable.register(SearchTableViewCell.self, forCellReuseIdentifier: "searchCell")
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
    
    func sortFunc(num1: Int, num2: Int) -> Bool {
        return num1 < num2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        var index = Int(searchText) ?? -1
        index = index - 1
        
        if index == -2{
            filteredLocations = array
        }
        else{
            if index > array.count{
                index = 0
            }
            else{
                filteredLocations = [array[index]]
            }
        }
        self.searchTable.reloadData()
    }
    
}

extension StationSearchViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredLocations.count
        }
        
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
        let poll: PollStation
        if isFiltering() {
            poll = filteredLocations[indexPath.row]
        } else {
            poll = array[indexPath.row]
        }
        cell.resultLabel.text = poll.location_name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var poll: PollStation
        if isFiltering(){
            poll = filteredLocations[indexPath.row]
        }
        else{
            poll = array[indexPath.row]
        }
        if searchController.isActive == true {
            searchController.dismiss(animated: true, completion: {
                print("🏢 Tapped \(poll)")
                let station =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Station") as! StationViewController
                station.fromModal = true
                station.tappedStation = poll
                self.parent?.present(station, animated: true, completion: nil)
            })
        }
        else{
            print("🏢 Tapped \(poll)")
            let station =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Station") as! StationViewController
            station.fromModal = true
            station.tappedStation = poll
            self.parent?.present(station, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension StationSearchViewController: UISearchResultsUpdating {
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

extension StationSearchViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
}
