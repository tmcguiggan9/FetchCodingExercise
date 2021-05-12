
import UIKit
import Foundation


var events = [Event]()
var filteredEvents = [Event]()
var favoritedEvents = [String]()



let defaults = UserDefaults.standard

class ViewController: UITableViewController {

    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        
        let urlString = "https://api.seatgeek.com/2/events?client_id=MjE4MzgwODR8MTYyMDA2MjIzNC43NDgyNzUz"

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
            }
        }
        
        loadFavorited()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorited()
        tableView.reloadData()
    }
    
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonEvents = try? decoder.decode(Events.self, from: json) {
            events = jsonEvents.events
            tableView.reloadData()
        }
    }
    
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search for an event"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .systemPurple
            textField.backgroundColor = .white
           
        }
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredEvents.count : events.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        let event = inSearchMode ? filteredEvents[indexPath.row] : events[indexPath.row]
        let performer = event.performers[0].name
        cell.eventTitle.text = performer
        
        cell.heartIcon.isHidden = true
        cell.eventDateAndTime.text = utcToLocal(dateStr: event.datetime_utc)
        cell.eventLocation.text = event.venue.extended_address
        
        if event.isFavorited == true {
            cell.heartIcon.isHidden = false
        }
        
        
        let image = event.performers[0].image
        let url = URL(string: image)
        if let url = url {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    cell.eventImage.image = UIImage(data: data!)
                }
            }
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.event = inSearchMode ? filteredEvents[indexPath.row] : events[indexPath.row]
        vc.indexPath = indexPath.row
        vc.isFiltered = inSearchMode ? true : false
        navigationController?.pushViewController(vc, animated: true)
        print(events[indexPath.row].isFavorited)
        
    }
    
   
    
    func loadFavorited() {
        favoritedEvents = defaults.array(forKey: "FavoritedEvents") as! [String]
        
        for x in 0..<events.count {
            if favoritedEvents.contains(events[x].performers[0].name) {
                events[x].isFavorited = true
            }
        }
    }
    
    func utcToLocal(dateStr: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "YYYY-MM-dd H:mm"

        let showDate = inputFormatter.date(from: dateStr)
        let resultString = outputFormatter.string(from: showDate!)

        return resultString
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        

        filteredEvents = events.filter({ event -> Bool in
            return event.performers[0].name.contains(searchText) || event.venue.extended_address.contains(searchText)
        })
        
        self.tableView.reloadData()
    }
}
