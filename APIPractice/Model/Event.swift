
import Foundation



struct Events: Codable {
    var events: [Event]
}

struct Event: Codable {
    var performers: [Performer]
    var datetime_utc: String
    var venue: Venue
    var isFavorited: Bool = false
}


struct Performer: Codable {
    var name: String
    var image: String
}


struct Venue: Codable {
    var extended_address: String
}

extension Event {
    enum CodingKeys: CodingKey {
        case performers
        case datetime_utc
        case venue
    }
    
   
}
