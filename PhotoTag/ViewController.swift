//
//  ViewController.swift
//  PhotoTag
//
//

import UIKit
import Photos
import FirebaseDatabase

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    private var foregroundObserver: NSObjectProtocol?
    
    // Storyboard outlets
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var navSearchButton: UIBarButtonItem!
    @IBOutlet weak var navSettingsButton: UIBarButtonItem!
    var searchBar: UISearchBar!
    
    // Class variables
    var username = ""
    var user: User!
    var loadingPhotos: Bool = true
    var processingAllPhotos: Bool = false

    var numPhotosSynced = 0
    var searchResults: Set<String> = []  //a set of the photo objects returned by the search
    var totalSearchTerms = 0        //the total number of search terms
    var searchCounter = 0           //the number of search terms already retrieved by DB
    
    var scheduleList: [[String: Any]] = []

    
    let galleryViewCellNibName = "GalleryCollectionViewCell"
    let galleryViewCellIdentifier = "GalleryItem"
    let singlePhotoSegueIdentifier = "SinglePhotoViewSegue"
    let searchResultsSegueIdentifier = "SearchResultsViewSegue"
    let mapViewSegueIdentifier = "MapViewSegue"

    let autoTagGlobalVarName = "Autotag"
    let onDeviceProcessingGlobalVarName = "Servertag"
    
    let syncedPhotosSemaphore = DispatchSemaphore(value: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        addHiddenSearchBar()
        
        user = User(un: username)
        print("Username: ", username)
        UserDefaults.standard.set(username, forKey: "Username")
        
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        searchBar.delegate = self
        
        // Register and modify the display of individual gallery elements within the gallery collection view
        registerGalleryItemNib()
        viewWillLayoutSubviews()
        
        /*
        // Register a new foreground observer to notify the application when it has re-entered the foreground (main application)
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            getGalleryPermission(callback: postPermissionCheck, failure: failedPermissionCheck)
            // PHPhotoLibrary.shared().register(self)
        }
 */
        
        // searchBarListener()
        getGalleryPermission(callback: postPermissionCheck, failure: failedPermissionCheck)
        
    }
    
    //MARK: Search functions
    
    //onClick for the search button in the Nav bar
    @IBAction func onClick(_ sender: Any) {
        if sender as? NSObject == navSearchButton {
            // Navbar - Search
            if self.searchBar!.frame.minY != self.galleryCollectionView.frame.minY {
                // Search bar is hidden so display it
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.searchBar!.frame = CGRect(x: 0.0, y: self.galleryCollectionView.frame.minY, width: self.view.frame.width, height: 40.0)
                }, completion: { (Bool) -> Void in
                    self.searchBar?.becomeFirstResponder()
                })
            } else {
                // Search bar is visible so hide it
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.searchBar!.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 40.0)
                }, completion: { (Bool) -> Void in
                    self.searchBar?.resignFirstResponder()
                })
            }
        }
    }

    /*
     *   function that triggers the DB search. Called when
     *   the search button is pressed on the keyboard
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()    //resigns the keyboard
        searchCounter = 0   //reset the counter for search terms
        searchResults.removeAll()   //clear out the search results
        
//        var tagString = ""              //the tag being searched
//        var foundPhotos: Set<String> = []  // A set of the photo objects returned by the search

        var ref: DatabaseReference!     //reference to the database
        ref = Database.database().reference()
        
        //get the tag from the search bar
        if let searchString = searchBar.text?.lowercased() {
            user.getAllTags { (tags: [String]) in
                DispatchQueue.main.async {
                    print("Find tags from this search string: \(searchString)")
                    print("Finding tags from this list: \(tags)")
                    let searchKeys: [String] = Search.getTagsFromText(searchText: searchString, tags: tags)
                    print("Found these tags: \(searchKeys)")
                    
                    //set the totalSearchTerms
                    self.totalSearchTerms = searchKeys.count
                    
                    for key in searchKeys {  //for each term the user is searching for
                        //search the database for that tag
                        print("searching DB for: |\(key)|")
                        //ref = ref.child("iOS/\(user.username)/photoTags/\(key)")
                        let tempRef = ref.child("iOS/\(self.user.username)/photoTags/\(key)")
                        tempRef.getData(completion: { (error, snapshot) in
                            if let error = error {
                                print("Error getting data for tag: \(key). Error: \(error)")
                            } else if !snapshot.exists() {
                                print("At least one of these tags was not found. Please try again")
                                self.presentEmptySearchDialogue()
                            } else {
                                //let the callback handle adding the new entries into the combined list
                                
                                self.searchCounter += 1
                                
                                var tempIds: Set<String> = []
                                for child in snapshot.children {
                                    let childTag = child as! DataSnapshot
                                    let id = childTag.key
                                    // self.searchResults.insert(id)
                                    tempIds.insert(id)
                                }
                                
                                if self.searchResults.count == 0 {
                                    self.searchResults = tempIds
                                } else {
                                    self.searchResults = tempIds.intersection(self.searchResults)
                                }
                                
                                self.processSearchResults()
                                
                                // print("ids for \(key): \(snapshot.value as! [String])")
                                // self.processSearchResults(photoIds: snapshot.value as! [String])
                            }
                        })
                    }
                }
            }
        }
    }
    
    /*
     *  Callback function for searching multiple tags.
     *  this function adds the sent ids to the class-level
     *  search results array as a join, one search term at a time.
     */
    private func processSearchResults(){
        //if that was the last term, segue to the search results view
        if searchCounter == totalSearchTerms{
            //as long as the result list is not empty
            if !searchResults.isEmpty{
                print("Segue to photo display with photos: \(searchResults)")
                self.segueToSearchResults(photos: Array(searchResults))
            }else{
                presentEmptySearchDialogue()
            }
        }
    }
    
    //executes the segue between the gallery view and the search results view controller
    //ALSO handles converting the photo IDs into a list of the local photo objects
    private func segueToSearchResults(photos: [String]){
        var photoObjects = [Photo]()
        
        for id in photos{
            print("trying id \(id)")
            
            // Only add the photo object to the results list if the photo object exists locally
            let tempPhoto = user.getPhoto(id: id)
            if tempPhoto != nil {
                print("Adding photo")
                photoObjects.append(tempPhoto!)
            } else {
                print("Photo not found")
            }
            
        }//photoObjects contains the local photo objects, not just their IDs
        
        //open the search results view controller
        dispatch_queue_main_t.main.async() {
            self.performSegue(withIdentifier: self.searchResultsSegueIdentifier, sender: photoObjects)
        }
    }
    
    //shows a dialogue box informing the user of an empty search
    private func presentEmptySearchDialogue(){
        
        dispatch_queue_main_t.main.async() {
            let alert = UIAlertController(title: "No photos found", message: "At least one of these tags was not found. Please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    /*
     * Add a search bar
     */
    private func addHiddenSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 40.0))
        self.view.addSubview(searchBar!)
    }
    
    //MARK: Permissions functions
    
    /*
     * Callback function after gallery permissions have been sucessfully granted
     */
    private func postPermissionCheck() {
        print("Got the needed permissions")
        getSchedulesFromDb {
            self.loadPhotos()
        }
    }
    
    /*
     * Callback function after gallery permissions have NOT been granted
     */
    private func failedPermissionCheck() {
        print("Did not receive the appropriate permission to view gallery")
    }
    
    
    /*
     * Checks the user permission to make sure the application has access to the local photo gallery
     * @param   callback    Callback function to continue application execution post approval
     * @param   callback    Callback function upon failure of getting permission
     */
    private func getGalleryPermission(callback: @escaping () -> (), failure: @escaping () -> ()) {
        let photosCheck = PHPhotoLibrary.authorizationStatus()
        
        // Cheeck if app has access to users local photo gallerey
        if (photosCheck == .notDetermined) {
            // Request read and write permission for photo gallery
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (accessStatus) in
                if (accessStatus == .authorized) {
                    // Successfully granted access to photo gallery
                    callback()
                } else {
                    // User denied the application access to the photo gallery
                    failure()
                }
            }
        } else if (photosCheck == .authorized) {
            // User already authorized access to the gallery before
            callback()
        }
    }
    
    /*
     * Process all of the photos in the gallery view
     */
    private func processAllPhotos() {
        print("Processing all photos")
        
        if processingAllPhotos == true {
            print("Exiting processing photos. Photos already being processed")
            return
        }
        
        if let autoTagCheck: Bool = UserDefaults.standard.object(forKey: autoTagGlobalVarName) as? Bool {
            
            if let serverProcessCheck: Bool = UserDefaults.standard.object(forKey: onDeviceProcessingGlobalVarName) as? Bool {
                
                print("Autotag: \(autoTagCheck)")
                print("Server side processing: \(serverProcessCheck)")
                
                if autoTagCheck == true {
                    processingAllPhotos = true
                    let labeler = MLKitProcess()
                    
                    labeler.labelAllPhotos(photos: user.photos, serverProcess: serverProcessCheck, username: user.username) {() in
                        self.processingAllPhotos = false
                        print("Done processing all photos")
                    }
                }
            } else {
                print("Server side processing tag not found. Defaulting to on device processing if autotag is on.")
                print("Autotag: \(autoTagCheck)")
                if autoTagCheck == true {
                    processingAllPhotos = true
                    let labeler = MLKitProcess()
                    
                    labeler.labelAllPhotos(photos: user.photos, serverProcess: false, username: user.username) {() in
                        self.processingAllPhotos = false
                        print("Done processing all photos")
                    }
                }
            }
        }
    }
    
    /*
     * Callback function used upon syncing photo object from db to check when all photos have been synced.
     * Needed to know when to start processing all photos since we need to sync if the object has already been
     *      autotagged or not.
     */
    private func doneSyncingPhoto() {
        syncedPhotosSemaphore.wait()
        numPhotosSynced += 1
        let numSyncedTemp = numPhotosSynced
        let totalPhotosTemp = self.user.getPhotoCount()
        syncedPhotosSemaphore.signal()
        
        print("Synced: \(numSyncedTemp)/\(totalPhotosTemp) photos")
        
        if numSyncedTemp == totalPhotosTemp {
            // Done syncing all photos from database
            self.processAllPhotos()
        }
    }
    
    private func getSchedulesFromDb(callback: @escaping () -> ()) {
        //tag schedule populating starts here
        //CountDownLatch done = new CountDownLatch(1)
        let ref: DatabaseReference = Database.database().reference()
        let tempRef = ref.child("iOS/\(self.user.username)/Schedules/")
        tempRef.getData(completion: { (error, snapshot) in
            if let error = error {
                print("Error getting data for schedules: Error: \(error)")
                callback()
            }else {
                //let the callback handle adding the new entries into the combined list
                
                for child in snapshot.children {
                    let childDict = child as! DataSnapshot

                    guard let values = childDict.value as? [String: Any] else{
                        return
                    }
                    let startDate = values["start date"] as! String
                    let endDate = values["end date"] as! String
                    let startTime = values["start time"] as! String
                    let endTime = values["end time"] as! String
                    let days = values["days"] as! String
                    let tag = values["tag"] as! String
                    
                    let tempSchedule = ["start date" : startDate,
                                           "end date" : endDate,
                                           "start time" : startTime,
                                           "end time" : endTime,
                                           "days" : days,
                                           "tag" : tag
                    ]
                    self.scheduleList.append(tempSchedule)
                    //print(self.scheduleList, Date())
                }
                callback()
            }
        })
    }
    
    /*
     * Create a list referncing all the local photos the application has access to
     * Is only refreshing photos, specify which index the photos should be added at
     * @param   Bool    Indcates if this is the first time the photos are being added or if the photos are being refreshed
     */
    private func loadPhotos() {
        print("Loading photos")
        
        // Create a background task
        DispatchQueue.global(qos: .utility).async {
        
            // Create fetch options to return photos in order of creation
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            // Retrieve local photos (photos only, no video)
            let photoResults: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            let ref: DatabaseReference = Database.database().reference()
            
            //end of populate schedules
            var counter = 0
            if (photoResults.count > 0) {
                for i in 0..<photoResults.count {
                    //*****start tag scheduling******
                    //loop through all schedules
                    let pDate: Date? = photoResults[i].modificationDate
                   //print("Date of Photo:", pDate)
                    if let pDate = pDate{
                        //print(396, self.scheduleList, Date())
                        //if current photo has a date
                        for schedule in self.scheduleList {
                            let d1:Date = self.dateStrToDate(str: schedule["start date"] as! String)
                            let d2:Date = self.dateStrToDate(str: schedule["end date"] as! String)
                            let t1:String = schedule["start time" ] as! String
                            let t2:String =  schedule["end time"] as! String
                            let dayMaskStr:String =  schedule["days"] as! String
                            let dayMask:Int = Int(dayMaskStr)!
                            if self.inDateRange(photoDate: pDate, date1: d1, date2: d2) == 1{
                                //date is in range of dates
                                if  self.inTimeRange(photoDate: pDate, time1: t1, time2: t2) == 1{
                                    //date is in range of times
                                    if self.dayOfWeekMatch(maskedInt: dayMask, date: pDate) {
                                        //on day of week
                                        print("Scheduled tag added for: " , pDate)
                                        //check if tag is already there?
                                        //database references
                                        let photoRef =  ref.child("iOS/\(self.user.username)/Photos/")
                                        let tagRef = ref.child("iOS/\(self.user.username)/photoTags")
                                        var photoID = photoResults[i].localIdentifier
                                        photoID = Photo.firebaseEncodeString(str: photoID)
                                        
                                        var tag = schedule["tag"] as! String
                                        tag = tag.trimmingCharacters(in: .whitespacesAndNewlines) //clean up tag
                                        
                                        photoRef.child(photoID).child("photo_tags").child(tag).setValue(true) //save
                                        tagRef.child(tag).child(photoID).setValue(true)
                                    }
                                }
                            }else{
                                print("not adding tag")
                            }
                            //print("Date:", photoResults[i].modificationDate)
                        }
                    }
                    //******end of tag scheduling*****
                    
                    if !self.user.photosMap.contains(photoResults[i].localIdentifier) {
                        self.user.addPhoto(photo: Photo(asset: photoResults[i], username: self.user.username, callback: self.doneSyncingPhoto), index: counter)
                    }
                    counter += 1
                }
            } else {
                // Returing array is 0 indcating the application can not view any of the local photos
                print("No Photos were found")
            }
            
            // Callback after retrieveing images is complete
            DispatchQueue.main.async {
                print("Retrieved all local photos")
                self.loadingPhotos = false
                
                // Refresh the gallery collection view to display new gallery data
                print("Refreshing gallery collection view to display new photos")
                self.galleryCollectionView.reloadData()
            }
        }
    }
    
    
    // MARK: Single Gallery View Nib Functions
    
    /*
     * Registers the gallery collection view to use the GalleryItem cell as the primary view cell
     */
    private func registerGalleryItemNib() {
        let nib = UINib(nibName: galleryViewCellNibName, bundle: nil)
        
        // Register galleryItem (photo cell) xib file to the main gallery view
        galleryCollectionView.register(nib, forCellWithReuseIdentifier: galleryViewCellIdentifier)
    }
    
    /*
     * Override the default collection view cell look
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureCollectionViewItemSize()
    }
    
    /*
     * Set the size of the individual photo elements within the gallery colelction view
     */
    private func configureCollectionViewItemSize() {
        var collectionViewFlowLayout: UICollectionViewFlowLayout!
        let numPhotosPerRow: CGFloat = 4
        let lineSpacing: CGFloat = 5
        let interItemSpacing: CGFloat = 5
        
        let width = (view.frame.size.width - (numPhotosPerRow - 1) * interItemSpacing) / numPhotosPerRow
        let height = width
        
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
        collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.minimumLineSpacing = lineSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
        
        galleryCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
    }
    
    /*
     * Collection view function - Returns the number of individual cells the gallery view controler should display
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.user.getPhotoCount()
    }
    
    /*
     * Collection view function - Populates the individual gallery view cells with their associated photo
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryItem", for: indexPath) as! GalleryCollectionViewCell
        
        // let photo = user.photos[indexPath.item]
        let photo = user.getPhoto(index: indexPath.item)
        
        cell.imageDisplay.image = photo.getPreviewImage()
        return cell
    }
    
    /*
     * Collection view function - Handles user selecting an image from the gallery view
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        //let photo = user.photos[indexPath.item]
        let photo = user.getPhoto(index: indexPath.item)

        performSegue(withIdentifier: self.singlePhotoSegueIdentifier, sender: photo)
    }
    
    //MARK: Segue Preparation
    
    /*
     * Segue action prepare statements. Helps send data between view controllers upon a new segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == singlePhotoSegueIdentifier {
            //this assignmnet needs to be in here in the event that we want to segue to settings
            //let item = sender as! Photo
            if let viewController = segue.destination as? SinglePhotoViewController {
                viewController.photo = (sender as! Photo)
            }
        }
        else if segue.identifier == searchResultsSegueIdentifier{
            if let viewController = segue.destination as? SearchResultsViewController{
                viewController.photos = sender as! [Photo]
            }
        }
        else if segue.identifier == mapViewSegueIdentifier{
            if let viewController = segue.destination as? MapViewController{
                viewController.user = user
            }
        }
    }
    
    deinit {
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
    }
    
    
    /*
     checks if a photo was taken within a scheduled date range
     * @param   PhotoDate: Date to see if range, date1: first date, date2: last date
     * @return  1: true, -1: false, other flags for future optimization
     */
    func inDateRange(photoDate: Date, date1: Date, date2: Date) -> Int{
        if photoDate >= date1 && photoDate <= date2{
        //dateInRange
            return 1
        }
        return -1
    }
    
    func inTimeRange(photoDate: Date, time1: String, time2: String) -> Int{
        
        var t1:Int = timeStrToTime(str: time1)
        var t2:Int = timeStrToTime(str: time2)
        var pTime:Int = dateToJustMinutes(date: photoDate)

        if pTime >= t1 && pTime <= t2{
        //timeInRange
           return 1
        }
        return -1
    }
    
    /*
     * Parse string as Date
     * @param   String  String in format "MM/dd/yy, hh:mm a"
     * @return  Date , .short, .short
     */
    func dateStrToDate(str: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy, hh:mm a"
        let newDate = formatter.date(from: str)
        //print(newDate)
        return newDate!
    }
    
    /*
     * Parse string as time
     * @param   String  String in format hh:mm a"
     * @return  Date , .short, .short
     */
    func timeStrToTime(str: String) -> Int{
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.timeZone = TimeZone.current
        let date = formatter.date(from: str)
        print(date ?? "")
        
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date!)
        let hour = comp.hour ?? 0
        let minute = comp.minute ?? 0
        let finalT:Int = (hour * 60) + minute
        //print("TIME:", finalT, "Was:", str)
        return finalT
    }
    
    func dateToJustMinutes(date: Date) -> Int{
        
        let dFormatter = DateFormatter()
        dFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dFormatter.locale = Locale(identifier: "en_US_POSIX")
        dFormatter.dateFormat = "HH:mm"
        let now = dFormatter.string(from: date)
        let now2 = dFormatter.date(from: now)

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let comp = calendar.dateComponents([.hour, .minute], from: now2!)
        let hour = comp.hour ?? 0
        let minute = comp.minute ?? 0
        
        let finalT:Int = (hour * 60) + minute
        //print("TIME:", finalT, "Was:", now)
        return finalT
    }
    
    /*
     * Encode a string to be firebase key friendly
     * @param   String  String to encode
     * @return  String  Endoded, firebase friendly, string
     */
    static func firebaseEncodeString(str: String) -> String {
        var newStr = str
        newStr = newStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        newStr = newStr.replacingOccurrences(of: ".", with: "---|")
        newStr = newStr.replacingOccurrences(of: "#", with: "--|-")
        newStr = newStr.replacingOccurrences(of: "$", with: "-|--")
        newStr = newStr.replacingOccurrences(of: "[", with: "|---")
        newStr = newStr.replacingOccurrences(of: "]", with: "|--|")
        return newStr
    }
    
    
    func dayOfWeekMatch(maskedInt: Int, date: Date)-> Bool{
        //let dayOfWeek = Calendar.current.component(.weekday, from: date)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "ccc"
        let dayOfWeek = dateFormatter.string(from: date)
        var mask = maskedInt
        
        var dayAsInt = 0;
        print("DAY", dayOfWeek)
        if dayOfWeek == "Mon"{
            dayAsInt = 1
        }
        if dayOfWeek == "Tue"{
            dayAsInt = 2
        }
        if dayOfWeek == "Wed"{
            dayAsInt = 4
        }
        if dayOfWeek == "Thu"{
            dayAsInt = 8
        }
        if dayOfWeek == "Fri"{
            dayAsInt = 16
        }
        if dayOfWeek == "Sat"{
            dayAsInt = 32
        }
        if dayOfWeek == "Sun"{
            dayAsInt = 64
        }
        //unmask
        if(mask <= dayAsInt){
            return true
        }else{
            mask = mask - 64 //sunday
        }
        if(mask <= dayAsInt){
            return true
        }else{
            mask = mask - 32 //sat
        }
        if(mask <= dayAsInt){
            return true
        }else{
            mask = mask - 16 //fri
        }
        if(mask <= dayAsInt){
            return true
        }else{
            mask = mask - 8//thu
        }
        if(mask <= dayAsInt){
            return true
        }else{
            mask = mask - 4//wed
        }
        if(mask <= dayAsInt){
            return true
        }else{
            mask = mask - 2//tue
        }
        if(mask <= dayAsInt){
            return true
        }else{
            mask = mask - 1 //mon
        }
        
        return false
        
    }
    
    
}

