import UIKit
import AVFoundation
import AVKit

class PlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var thumbNailImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var songLoading: UIActivityIndicatorView!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var randomLED: UILabel!
    @IBOutlet weak var loopLED: UILabel!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var settignsButton: UIButton!
    @IBOutlet weak var urlInfoLabel: UILabel!
    
    var playList: NSMutableArray = NSMutableArray()
    var infoSongList: Array<String> = Array()
    var timer: Timer?
    var index: Int = Int()
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var songs:[String] =  []
    var countIndex: Int = Int()
    var blur_counter : Int = 0
    var randomStatus: Bool! = false
    var loopStatus: Bool! = false
    var bottomTable: Bool! = false
    var urlFieldStatus: Bool! = false
    var urlAdress = UserDefaults.standard.object(forKey: "urlAdress") as? String
    
    //unwarp "!" (self.urlAdress) from 113 and 125 line before use
    //var urlAdress = "http://stacja-meteo.pl/mp3"
    
    @IBOutlet weak var song_author: UILabel!
    @IBOutlet weak var image_cover: UIImageView!
    @IBOutlet weak var song_title_label: UILabel!
    @IBOutlet weak var music_list: UITableView!
    @IBOutlet weak var background_image: UIImageView!
    @IBOutlet weak var scrolling_image: UIImageView!
    @IBOutlet weak var next_artwork: UIImageView!
    @IBOutlet weak var prev_image: UIImageView!
   
    @IBOutlet weak var pear_yolo: UIImageView!
    @IBOutlet weak var infoSongTable: UITableView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func settignsButtonPress(_ sender: Any) {
        
        if (urlFieldStatus == true){
            self.urlField.isHidden = false
            self.urlInfoLabel.isHidden = false
            urlFieldStatus = false
        }
        
        else if(urlFieldStatus == false){
            
            UserDefaults.standard.set(self.urlField.text, forKey: "urlAdress")
            
            self.urlField.isHidden = true
            self.urlInfoLabel.isHidden = true
            urlFieldStatus = true
        }
        
        
    }
    @IBAction func randomPress(_ sender: Any) {
    
        if randomStatus == false{
            randomLED.textColor = UIColor.green
            randomStatus = true
            
            //turn off loop
            loopLED.textColor = UIColor.lightGray
            loopStatus = false
        }
        
        else if randomStatus == true{
            randomLED.textColor = UIColor.lightGray
            randomStatus = false
        }
        
    }
    @IBAction func loopPress(_ sender: Any) {
    
        if loopStatus ==  false{
            loopLED.textColor = UIColor.green
            loopStatus = true
            
            //turn off random
            randomLED.textColor = UIColor.lightGray
            randomStatus = false
        }
        
        else if loopStatus ==  true{
            loopLED.textColor = UIColor.lightGray
            loopStatus = false
        }
    }
    
    func getMp3() {
        
        let url = URL(string: self.urlAdress!)!
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localURL = localURL {
                if let string = try? String(contentsOf: localURL) {

                    let regex = try! NSRegularExpression(pattern:"href=(.*?)>", options: [])
                   

                    regex.enumerateMatches(in: string, options: [], range: NSMakeRange(0, string.utf16.count)) { result, flags, stop in
                        if let r = result?.range(at: 1), let range = Range(r, in: string) {
                           
                            if (String(String(string[range]).toLengthOf(length: 1).dropLast())).contains(".mp3"){
                                self.playList.add(self.urlAdress! + "/" + String(String(string[range]).toLengthOf(length: 1).dropLast()))
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMp3()
        
        self.urlField.addTarget(nil, action:Selector("firstResponderAction:"), for:.editingDidEndOnExit)

    
        delayWithSeconds(1.5) {
            self.pear_yolo.isHidden = true
            super.viewWillAppear(animated)
            self.isPaused = false
            
            self.playButton.setImage(UIImage(named:"pause_circle"), for: .normal)
            self.play(url: URL(string:(self.playList[self.index] as! String))!)
            
            self.music_list.isHidden = true
            self.infoSongTable.isHidden = true
            
            self.urlField.isHidden = true
            self.urlInfoLabel.isHidden = true
            
            if let x = UserDefaults.standard.object(forKey: "urlAdress") as? String
            {
                self.urlField.text = x
            }
        
            self.gettingSongName()
            
            self.setupTimer()
            
            self.image_cover.layer.shadowColor = UIColor.black.cgColor
            self.image_cover.layer.shadowOpacity = 1
            self.image_cover.layer.shadowOffset = CGSize.zero
            self.image_cover.layer.shadowRadius = 30
            
            self.initArtwork()
            self.initNextArtwork()
            self.initPrevArtwork()
            
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeActionRight(swipe:)))
            rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
            self.view.addGestureRecognizer(rightSwipe)
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeActionLeft(swipe:)))
            leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
            self.view.addGestureRecognizer(leftSwipe)
            
            let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeActionDown(swipe:)))
            downSwipe.direction = UISwipeGestureRecognizer.Direction.down
            self.view.addGestureRecognizer(downSwipe)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
            self.view.addGestureRecognizer(longPress)
            
            self.scrolling_image.isUserInteractionEnabled = true
            
            let RotationScrolling = UIRotationGestureRecognizer(target: self, action: #selector(self.Rotation))
            self.scrolling_image.addGestureRecognizer(RotationScrolling)
            
            self.readSongInfo()
            
        }
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            infoSongTable.isHidden = false
        }
        if sender.state == .ended {
            infoSongTable.isHidden = true
        }
    }
    
    @objc func Rotation(sender: UIRotationGestureRecognizer){
        
        let sliderNow = playerSlider.value
       
        let sliderRotation = sender.velocity
        let sliderNewTime = sliderNow + Float(sliderRotation)
        
        let seconds : Int64 = Int64(sliderNewTime)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        avPlayer!.seek(to: targetTime)
        
        sender.view?.transform = (sender.view!.transform).rotated(by: sender.rotation)
        sender.rotation = 0
    }
   
    func hideTable(){
        UITableView.transition(with: music_list, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            self.music_list.frame = self.CGRectMake(15, 800, self.music_list.frame.width
                , self.music_list.frame.height)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.music_list.isHidden = true
            self.image_cover.isHidden = false
            
            if (self.index == 0){
            // prev artwork is hidden
            }
            else{
            self.prev_image.isHidden = false
            }
            let items = self.playList.count
            if ( self.index == items){
            // next artwork is hidden
            }
            else{
            self.next_artwork.isHidden = false
            }
            self.bottomTable = false
            
        }
    }
    
    func showTable(){
        self.music_list.isHidden = false
        UITableView.transition(with: music_list, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            self.music_list.frame = self.CGRectMake(15, 25, self.music_list.frame.width
                , self.music_list.frame.height)
        })
        bottomTable = true
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    @objc func swipeActionRight(swipe:UISwipeGestureRecognizer)
    {
        self.prevTrack()
    }
    
    @objc func swipeActionLeft(swipe:UISwipeGestureRecognizer)
    {
        self.nextTrack()
    }
    
    @objc func swipeActionDown(swipe:UISwipeGestureRecognizer)
    {
        if(music_list.isHidden == false){
            hideTable()
           // image_cover.isHidden = false
        }
        else if (music_list.isHidden == true){
            image_cover.isHidden = true
            next_artwork.isHidden = true
            prev_image.isHidden = true
            showTable()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == music_list){
            return songs.count
        }
        
        else if (tableView == infoSongTable){
            return infoSongList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == music_list {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = songs[indexPath.row]
        
        tableView.backgroundColor = .clear
        cell.backgroundColor = .clear
        tableView.backgroundColor = UIColor.darkGray
        cell.textLabel?.textColor = UIColor.white
        
        tableView.layer.borderWidth = 2.0;
        tableView.layer.cornerRadius = 5.0;
        tableView.layer.borderColor = UIColor.lightGray.cgColor;

        return cell
        }
        
        else if tableView == infoSongTable{
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = infoSongList[indexPath.row]
   
            tableView.backgroundColor = .clear
            cell.backgroundColor = .clear
            tableView.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.white
 
            tableView.layer.borderWidth = 2.0;
            tableView.layer.cornerRadius = 5.0;
            tableView.layer.borderColor = UIColor.lightGray.cgColor;
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == music_list{
            let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
            selectedCell.contentView.backgroundColor = UIColor.gray
    
            self.play(url: URL(string:(playList[indexPath.row] as! String))!)
            self.setupTimer()
            index = indexPath.row
            initArtwork()
            initNextArtwork()
            initPrevArtwork()
            readSongInfo()
            playButton.setImage(UIImage(named:"pause_circle"), for: .normal)
            
        }
    }
    
    func play(url:URL) {
        self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        if #available(iOS 10.0, *) {
            self.avPlayer.automaticallyWaitsToMinimizeStalling = false
        }
        avPlayer!.volume = 1.0
        avPlayer.play()
      
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.metadata as! [AVMetadataItem]
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
        for item in metadataList {
            
            guard let key = item.commonKey?.rawValue, let value = item.value else{
                continue
            }
            
            switch key {
            case "title" : song_title_label.text = value as? String
            case "artist": song_author.text = value as? String
            case "artwork": do {
                if let audioImage = UIImage(data: value as! Data) {
                    
                    if (audioImage != nil){

                        background_image.image = audioImage
                        
                        if(blur_counter == 0){
                        background_image.addSubview(blurEffectView)
                        }
                        blur_counter = blur_counter + 1
                        
                    }
                    else{
                        //print("no artwork")
                        }
                    }
                }
            
            default:
                continue
            }
        }
    }
    
    func readSongInfo(){
        infoSongList.removeAll()
        countIndex = index
        let playerItem = AVPlayerItem(url: URL(string:(playList[self.countIndex] as! String))!)
        let metadataList = playerItem.asset.metadata as! [AVMetadataItem]
        
        var album = ""
        var type = ""
        //
        for item in metadataList {
            
            guard let key = item.commonKey?.rawValue, let value = item.value else{
                continue
            }
            
            switch key {
            case "albumName" : album = (value as? String)!
            infoSongList.append("Album: " + album)
            case "type" : type = (value as? String)!
            infoSongList.append("Typ: " + type)
           
            default:
                continue
            }
        }
        infoSongTable.reloadData()
      
    }
    
    func initNextSlider(){
        //create slider animation
        UIView.animate(withDuration: 1, animations: {
            self.prev_image.frame.origin.x -= 278
        }, completion: nil)
        
        UIView.animate(withDuration: 1, animations: {
            self.image_cover.frame.origin.x -= 278
        }, completion: nil)
        
        UIView.animate(withDuration: 1, animations: {
            self.next_artwork.frame.origin.x -= 278
        }, completion: nil)
        // back to old possition
        self.prev_image.frame.origin.x += 278
        self.image_cover.frame.origin.x += 278
        self.next_artwork.frame.origin.x += 278
    }
    
    func initPrevSlider(){
        //create slider animation
        UIView.animate(withDuration: 1, animations: {
            self.prev_image.frame.origin.x += 278
        }, completion: nil)
        
        UIView.animate(withDuration: 1, animations: {
            self.image_cover.frame.origin.x += 278
        }, completion: nil)
        
        UIView.animate(withDuration: 1, animations: {
            self.next_artwork.frame.origin.x += 278
        }, completion: nil)
        
        // back to old possition
        self.prev_image.frame.origin.x -= 278
        self.image_cover.frame.origin.x -= 278
        self.next_artwork.frame.origin.x -= 278
    }
  
    func initArtwork(){
        countIndex = index
        let playerItem = AVPlayerItem(url: URL(string:(playList[self.countIndex] as! String))!)
        let metadataList = playerItem.asset.metadata as! [AVMetadataItem]
        
        for item in metadataList {
            
            guard let key = item.commonKey?.rawValue, let value = item.value else{
                continue
            }
            
            switch key {
            case "artwork": do {
                if let audioImage = UIImage(data: value as! Data) {
                    if (audioImage != nil){
                        image_cover.image = audioImage
                    }
                    else{
                        
                        }
                    }
                }
            default:
                continue
            }
        }
    }
    
    func initNextArtwork(){
        if(index < playList.count-1){
            countIndex = index + 1
            let playerItem = AVPlayerItem(url: URL(string:(playList[self.countIndex] as! String))!)
            let metadataList = playerItem.asset.metadata as! [AVMetadataItem]
            
            for item in metadataList {
                
                guard let key = item.commonKey?.rawValue, let value = item.value else{
                    continue
                }
                
                switch key {
                case "artwork": do {
                    if let audioImage = UIImage(data: value as! Data) {
                        if (audioImage != nil){
                            next_artwork.image = audioImage
                        }
                        else{
                            
                            }
                        }
                    }
                default:
                    continue
                }
            }
            
        }else{
             //next_artwork.isHidden = true
        }
    }
    
    func initPrevArtwork(){
        if(index > 0){
            if bottomTable == false{
            prev_image.isHidden = false
            }
            countIndex = index - 1
            let playerItem = AVPlayerItem(url: URL(string:(playList[self.countIndex] as! String))!)
            let metadataList = playerItem.asset.metadata as! [AVMetadataItem]
            
            for item in metadataList {
                
                guard let key = item.commonKey?.rawValue, let value = item.value else{
                    continue
                }
                
                switch key {
                case "artwork": do {
                    if let audioImage = UIImage(data: value as! Data) {
                        if (audioImage != nil){
                            prev_image.image = audioImage
                        }
                        else{
                            
                            }
                        }
                    }
                default:
                    continue
                }
            }
            
        }else{
         prev_image.isHidden = true
        }
    }
    
    override func viewWillDisappear( _ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.avPlayer = nil
        self.timer?.invalidate()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func gettingSongName()
    {
        let elements = playList.count
        var artist = ""
        var title = ""
        var listLabel = ""
        do
        {
            for i in 0...elements-1
            {
                let playerItem = AVPlayerItem(url: URL(string:(playList[i] as! String))!)
                let metadataList = playerItem.asset.metadata as! [AVMetadataItem]
                
                for item in metadataList {
                    
                    guard let key = item.commonKey?.rawValue, let value = item.value else{
                        continue
                    }
                    
                    switch key {
                    case "title" : title = (value as? String)!
                    case "artist" : artist = (value as? String)!
                    
                    listLabel = artist + " - " + title
                    songs.append(listLabel)
                        
                    default:
                        continue
                    }
                }
            }
            
            music_list.reloadData()
        }
        catch
        {
            
        }
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            self.togglePlayPause()
        } else {
        }
    }
    
    @available(iOS 10.0, *)
    func togglePlayPause() {
        if avPlayer.timeControlStatus == .playing  {
            playButton.setImage(UIImage(named:"play_circle"), for: .normal)
            avPlayer.pause()
            isPaused = true
        } else {
            playButton.setImage(UIImage(named:"pause_circle"), for: .normal)
            avPlayer.play()
            isPaused = false
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        self.nextTrack()
    }
    
    @IBAction func prevButtonClicked(_ sender: Any) {
        self.prevTrack()
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        avPlayer!.seek(to: targetTime)
        if(isPaused == false){
            
            songLoading.isHidden = false
            songLoading.startAnimating()
        }
    }
    
    @IBAction func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        if let slider = sender.view as? UISlider {
            if slider.isHighlighted { return }
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            let seconds : Int64 = Int64(value)
            let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
            avPlayer!.seek(to: targetTime)
            
            if(isPaused == false){

                songLoading.isHidden = false
                songLoading.startAnimating()
            }
        }
    }
    
    func setupTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(PlayerViewController.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    @objc func didPlayToEnd() {
        self.nextTrack()
    }
    
    @objc func tick(){
        if(avPlayer.currentTime().seconds == 0.0){
            
            songLoading.isHidden = false
            songLoading.startAnimating()
            
        }else{
            
            songLoading.isHidden = true
            songLoading.stopAnimating()
        }
        
        if(isPaused == false){
            if(avPlayer.rate == 0){
                avPlayer.play()
            }
        }
        
        if((avPlayer.currentItem?.asset.duration) != nil){
            let currentTime1 : CMTime = (avPlayer.currentItem?.asset.duration)!
            let seconds1 : Float64 = CMTimeGetSeconds(currentTime1)
            let time1 : Float = Float(seconds1)
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = time1
            let currentTime : CMTime = (self.avPlayer?.currentTime())!
            let seconds : Float64 = CMTimeGetSeconds(currentTime)
            let time : Float = Float(seconds)
            self.playerSlider.value = time
            let leftTime_1 = Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.asset.duration)!))))
            let leftTime_2 = Int32(time)
            let leftTimeFinal = "-" + formatTimeFromSeconds(totalSeconds: (leftTime_1 - leftTime_2))
            timeLabel.text = leftTimeFinal
            currentTimeLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.currentTime())!)))))
            
        }else{
            playerSlider.value = 0
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = 0
            timeLabel.text = "L \(self.formatTimeFromSeconds(totalSeconds: Int32(CMTimeGetSeconds((avPlayer.currentItem?.currentTime())!))))"
        }
    }
    
    func nextTrack(){
        
        if loopStatus == true{
            isPaused = false
            playButton.setImage(UIImage(named:"pause_circle"), for: .normal)
            self.play(url: URL(string:(playList[self.index] as! String))!)
            readSongInfo()
            initNextSlider()
            initArtwork()
            initNextArtwork()
            initPrevArtwork()
        }
        else if randomStatus == true{
            let elements = playList.count
            index = Int.random(in: 0..<elements)
            isPaused = false
            playButton.setImage(UIImage(named:"pause_circle"), for: .normal)
            self.play(url: URL(string:(playList[self.index] as! String))!)
            readSongInfo()
            initNextSlider()
            initArtwork()
            initNextArtwork()
            initPrevArtwork()
        }
        else if(index < playList.count-1){
            index = index + 1
            isPaused = false
            playButton.setImage(UIImage(named:"pause_circle"), for: .normal)
            self.play(url: URL(string:(playList[self.index] as! String))!)
            readSongInfo()
            initNextSlider()
            initArtwork()
            initNextArtwork()
            initPrevArtwork()
        }
        else{
            index = 0
            isPaused = false
            playButton.setImage(UIImage(named:"pause_circle"), for: .normal)
             self.play(url: URL(string:(playList[self.index] as! String))!)
            readSongInfo()
            initNextSlider()
            initArtwork()
            initNextArtwork()
            initPrevArtwork()
        }
    }
    
    func prevTrack(){
        
        if(index > 0){
            index = index - 1
            isPaused = false
            playButton.setImage(UIImage(named:"pause_circle"), for: .normal)
             self.play(url: URL(string:(playList[self.index] as! String))!)
            readSongInfo()
            initPrevSlider()
            initArtwork()
            initNextArtwork()
            initPrevArtwork()
        }
    }
    
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        return String(format: "%02d:%02d", minutes,seconds)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.avPlayer = nil
            self.timer?.invalidate()
        }
    }
}
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension StringProtocol where Index == String.Index {
    func subString(after: String, before: String? = nil, options: String.CompareOptions = []) -> SubSequence? {
        guard let lowerBound = range(of: after, options: options)?.upperBound else { return nil }
        guard let before = before,
            let upperbound = self[lowerBound..<endIndex].range(of: before, options: options)?.lowerBound else {
                return self[lowerBound...]
        }
        return self[lowerBound..<upperbound]
    }
}

extension String {
    
    func toLengthOf(length:Int) -> String {
        if length <= 0 {
            return self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return self.substring(from: to)
            
        } else {
            return ""
        }
    }
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}
