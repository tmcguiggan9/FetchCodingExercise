
import UIKit


class DetailViewController: UIViewController {
    
    var event: Event?
    var indexPath: Int?
    var isFiltered: Bool?
    
    
    
    private var eventTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    private var eventImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 4.0
        return iv
    }()
    
    private var eventDate: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private var eventLocation: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private var favoritedButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.isEnabled = true
        button.setHeight(height: 50)
        button.addTarget(self, action: #selector(favoriteEvent), for: .touchUpInside)
        return button
    }()
    
    
    @objc func favoriteEvent() {
        
        if isFiltered == true {
            filteredEvents[indexPath!].isFavorited.toggle()
            
            if filteredEvents[indexPath!].isFavorited == true {
                favoritedEvents.append((event?.performers[0].name)!)
            } else {
                if let index = favoritedEvents.firstIndex(of: filteredEvents[indexPath!].performers[0].name){
                    favoritedEvents.remove(at: index)
                }
            }
            
            
        } else {
            events[indexPath!].isFavorited.toggle()
            
            if events[indexPath!].isFavorited == true {
                favoritedEvents.append((event?.performers[0].name)!)
            } else {
                if let index = favoritedEvents.firstIndex(of: events[indexPath!].performers[0].name){
                    favoritedEvents.remove(at: index)
                }
            }
        }
        

        saveItems()
        setButton()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        view.backgroundColor = .white
        
    }
    

    func configureUI() {
        
        view.addSubview(eventTitle)
        eventTitle.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 40)
        eventTitle.text = event?.performers[0].name
        
        view.addSubview(eventImage)
        eventImage.centerX(inView: view)
        eventImage.anchor(top: eventTitle.bottomAnchor, paddingTop: 10, width: 200, height: 200)
        
        let image = event!.performers[0].image
        let url = URL(string: image)
        if let url = url {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    self.eventImage.image = UIImage(data: data!)
                }
            }
        }
        
        view.addSubview(eventDate)
        eventDate.anchor(top: eventImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 15, paddingLeft: 10, paddingRight: 10)
        eventDate.text = utcToLocal(dateStr: event!.datetime_utc)
    
        
        
        view.addSubview(eventLocation)
        eventLocation.anchor(top: eventDate.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
        eventLocation.text = event?.venue.extended_address
        
        
        view.addSubview(favoritedButton)
        favoritedButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingBottom: 15, paddingRight: 15)
        favoritedButton.centerX(inView: view)
        
        
        setButton()
        
    }
    
    func setButton() {
        
        if isFiltered == true {
            if filteredEvents[indexPath!].isFavorited == true {
                favoritedButton.backgroundColor = .white
                favoritedButton.setTitle("Unfavorite", for: .normal)
                favoritedButton.setTitleColor(.red, for: .normal)
                print("event is favorited")
            } else {
                favoritedButton.setTitle("Favorite", for: .normal)
                favoritedButton.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                favoritedButton.setTitleColor(.white, for: .normal)
                print("event is unfavorited")
            }
            
        } else {
            if events[indexPath!].isFavorited == true {
                favoritedButton.backgroundColor = .white
                favoritedButton.setTitle("Unfavorite", for: .normal)
                favoritedButton.setTitleColor(.red, for: .normal)
                print("event is favorited")
            } else {
                favoritedButton.setTitle("Favorite", for: .normal)
                favoritedButton.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                favoritedButton.setTitleColor(.white, for: .normal)
                print("event is unfavorited")
            }
        }
        
        
    }
    
    func utcToLocal(dateStr: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "YYYY-MM-dd  H:mm"

        let showDate = inputFormatter.date(from: dateStr)
        let resultString = outputFormatter.string(from: showDate!)

        return resultString
    }
    
    func saveItems() {
        defaults.set(favoritedEvents, forKey: "FavoritedEvents")
    }
}
