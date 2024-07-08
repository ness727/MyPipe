import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    var videoUrl = "https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=10&key=키&regionCode=KR&videoCategoryId=10"
    var youtubeVideo: YoutubeVideo?
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        
        
        guard let thumbnailUrl = youtubeVideo?.items[indexPath.row].snippet.thumbnails.thumbnailsDefault?.url else { return UITableViewCell() }
        guard let title = youtubeVideo?.items[indexPath.row].snippet.title else { return UITableViewCell() }
        guard let publishedAt = youtubeVideo?.items[indexPath.row].snippet.publishedAt else { return UITableViewCell() }

        // 썸네일 설정
        if let url = URL(string: thumbnailUrl) {
            loadImage(from: url, into: cell.thumbnail)
        }

        
        // 타이틀 설정
        cell.title.text = title

        // 날짜 설정
        let isoFormatter = ISO8601DateFormatter()

        guard let date = isoFormatter.date(from: publishedAt) else {
            fatalError("날짜 변환 실패")
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC 기준으로 설정
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // "년-월-일 시간:분" 형식

        let formattedDateString = dateFormatter.string(from: date)
        cell.publishedAt.text = formattedDateString
        
    
        
        return cell
    }

    func loadImage(from url: URL, into imageView: UIImageView) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Image download or conversion failed: \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        getData()
    }
    
    func getData() {
        guard let url = URL(string: videoUrl) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil { print(error!); return }
            guard let jsonData = data else { return }
            
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(YoutubeVideo.self, from: jsonData)
                // print(decodedData.boxOfficeResult.dailyBoxOfficeList[0].movieNm)
                // print(decodedData.boxOfficeResult.dailyBoxOfficeList[0].audiAcc)
                print(decodedData.items[0].snippet.title)
                self.youtubeVideo = decodedData
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! YoutubeViewController
        let myIndexPath = table.indexPathForSelectedRow!
        let row = myIndexPath.row
        
        dest.videoId = youtubeVideo?.items[row].id ?? ""
    }
}

// MARK: - YoutubeVideo
struct YoutubeVideo: Codable {
    let items: [Item]
}

// MARK: - Item
struct Item: Codable {
    let snippet: Snippet
    let id: String
}

// MARK: - Snippet
struct Snippet: Codable {
    let publishedAt: String
    let title, description: String
    let thumbnails: Thumbnails
    
    enum CodingKeys: String, CodingKey {
        case publishedAt
        case title, description, thumbnails
    }
    
}

// MARK: - Thumbnails
struct Thumbnails: Codable {
    let thumbnailsDefault, medium, high, standard: Default?
    let maxres: Default?

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault = "default"
        case medium, high, standard, maxres
    }
}

// MARK: - Default
struct Default: Codable {
    let url: String
    let width, height: Int
}
