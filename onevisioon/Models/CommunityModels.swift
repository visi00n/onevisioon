import Foundation

struct CommunityChatMessage: Identifiable, Hashable, Codable {
    let id: UUID
    let roomKey: String
    let roomTitle: String
    let userID: String
    let authorName: String
    let handle: String
    let body: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case roomKey = "room_key"
        case roomTitle = "room_title"
        case userID = "user_id"
        case authorName = "author_name"
        case handle
        case body
        case createdAt = "created_at"
    }
}

struct CommunityChatMessageCreatePayload: Encodable {
    let roomKey: String
    let roomTitle: String
    let userID: String
    let authorName: String
    let handle: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case roomKey = "room_key"
        case roomTitle = "room_title"
        case userID = "user_id"
        case authorName = "author_name"
        case handle
        case body
    }
}

struct CommunityPresenceMember: Identifiable, Hashable, Codable {
    let userID: String
    let displayName: String
    let handle: String
    let currentRoomKey: String?
    let localRoomKey: String?
    let smallGroupKey: String?
    let country: String?
    let usaAreaCode: String?
    let lastSeenAt: Date

    var id: String { userID }

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case displayName = "display_name"
        case handle
        case currentRoomKey = "current_room_key"
        case localRoomKey = "local_room_key"
        case smallGroupKey = "small_group_key"
        case country
        case usaAreaCode = "usa_area_code"
        case lastSeenAt = "last_seen_at"
    }
}

struct CommunityPresenceUpsertPayload: Encodable {
    let userID: String
    let displayName: String
    let handle: String
    let currentRoomKey: String?
    let localRoomKey: String?
    let smallGroupKey: String?
    let country: String?
    let usaAreaCode: String?
    let lastSeenAt: Date

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case displayName = "display_name"
        case handle
        case currentRoomKey = "current_room_key"
        case localRoomKey = "local_room_key"
        case smallGroupKey = "small_group_key"
        case country
        case usaAreaCode = "usa_area_code"
        case lastSeenAt = "last_seen_at"
    }
}

struct CommunityPublicProfile: Identifiable, Hashable, Codable {
    let id: String
    let displayName: String?
    let handle: String?
    let bio: String?
    let instagram: String?
    let xHandle: String?
    let youtube: String?
    let country: String?
    let usaAreaCode: String?
    let isPublic: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case handle
        case bio
        case instagram
        case xHandle = "x_handle"
        case youtube
        case country
        case usaAreaCode = "usa_area_code"
        case isPublic = "is_public"
    }
}

struct CommunityPrayerFeedPost: Identifiable, Hashable, Codable {
    let id: UUID
    let userID: String
    let authorName: String
    let handle: String
    let prayerTopic: String
    let message: String
    let amens: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case authorName = "author_name"
        case handle
        case prayerTopic = "prayer_topic"
        case message
        case amens
        case createdAt = "created_at"
    }
}

struct CommunityPrayerFeedPostCreatePayload: Encodable {
    let userID: String
    let authorName: String
    let handle: String
    let prayerTopic: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case authorName = "author_name"
        case handle
        case prayerTopic = "prayer_topic"
        case message
    }
}

struct CommunityRoomDescriptor: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case general
        case smallGroup
        case local
    }

    let kind: Kind
    let key: String
    let title: String

    var id: String { key }
}

enum CountryDirectory {
    static let names: [String] = {
        Locale.Region.isoRegions
            .compactMap { Locale.current.localizedString(forRegionCode: $0.identifier) }
            .filter { !$0.isEmpty }
            .uniqued()
            .sorted()
    }()
}

enum USAreaCodeDirectory {
    static let codes: [String] = [
        "201", "202", "203", "205", "206", "207", "208", "209", "210", "212", "213", "214",
        "215", "216", "217", "218", "219", "220", "223", "224", "225", "227", "228", "229",
        "231", "234", "235", "239", "240", "248", "251", "252", "253", "254", "256", "260",
        "262", "267", "269", "270", "272", "274", "276", "279", "281", "283", "301", "302",
        "303", "304", "305", "307", "308", "309", "310", "312", "313", "314", "315", "316",
        "317", "318", "319", "320", "321", "323", "324", "325", "326", "327", "329", "330",
        "331", "332", "334", "336", "337", "339", "340", "341", "346", "347", "350", "351",
        "352", "353", "357", "360", "361", "363", "364", "369", "380", "385", "386", "401",
        "402", "404", "405", "406", "407", "408", "409", "410", "412", "413", "414", "415",
        "417", "419", "423", "424", "425", "430", "432", "434", "435", "436", "440", "442",
        "443", "445", "447", "448", "457", "458", "463", "464", "469", "470", "471", "472",
        "475", "478", "479", "480", "483", "484", "501", "502", "503", "504", "505", "507",
        "508", "509", "510", "512", "513", "515", "516", "517", "518", "520", "530", "531",
        "534", "539", "540", "541", "551", "557", "559", "561", "562", "563", "564", "567",
        "570", "571", "572", "573", "574", "575", "580", "582", "585", "586", "601", "602",
        "603", "605", "606", "607", "608", "609", "610", "612", "614", "615", "616", "617",
        "618", "619", "620", "621", "623", "624", "626", "628", "629", "630", "631", "636",
        "640", "641", "645", "646", "650", "651", "656", "657", "659", "660", "661", "662",
        "667", "669", "670", "671", "678", "679", "680", "681", "682", "684", "686", "689",
        "701", "702", "703", "704", "706", "707", "708", "712", "713", "714", "715", "716",
        "717", "718", "719", "720", "724", "725", "726", "727", "728", "729", "730", "731",
        "732", "734", "737", "738", "740", "743", "747", "748", "754", "757", "760", "762",
        "763", "765", "769", "770", "771", "772", "773", "774", "775", "779", "781", "785",
        "786", "787", "801", "802", "803", "804", "805", "806", "808", "810", "812", "813",
        "814", "815", "816", "817", "818", "820", "821", "826", "828", "830", "831", "832",
        "835", "837", "838", "839", "840", "843", "845", "847", "848", "850", "854", "856",
        "857", "858", "859", "860", "861", "862", "863", "864", "865", "870", "872", "878",
        "901", "903", "904", "906", "907", "908", "909", "910", "912", "913", "914", "915",
        "916", "917", "918", "919", "920", "924", "925", "928", "929", "930", "931", "934",
        "936", "937", "938", "939", "940", "941", "943", "945", "947", "948", "949", "951",
        "952", "954", "956", "959", "970", "971", "972", "973", "975", "978", "979", "980",
        "983", "984", "985", "986", "989",
    ]
}

private extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
