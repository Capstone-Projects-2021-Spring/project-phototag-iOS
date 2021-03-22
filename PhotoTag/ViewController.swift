//
//  ViewController.swift
//  PhotoTag
//
//

import UIKit
import Photos
import FirebaseDatabase

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    // Storyboard outlets
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var navSearchButton: UIBarButtonItem!
    @IBOutlet weak var navSettingsButton: UIBarButtonItem!
    var searchBar: UISearchBar!
    
    // Class variables
    let user = User(un: "testUsername")
    var numPhotosSynced = 0
    var searchResults = [String]()  //an array of the photo objects returned by the search
    var totalSearchTerms = 0        //the total number of search terms
    var searchCounter = 0           //the number of search terms already retrieved by DB
    
    let galleryViewCellNibName = "GalleryCollectionViewCell"
    let galleryViewCellIdentifier = "GalleryItem"
    let singlePhotoSegueIdentifier = "SinglePhotoViewSegue"
    let searchResultsSegueIdentifier = "SearchResultsViewSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHiddenSearchBar()
        
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        searchBar.delegate = self
        
        // Register and modify the display of individual gallery elements within the gallery collection view
        registerGalleryItemNib()
        viewWillLayoutSubviews()
        
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
        
        var searchKeys = [String]()     //the list of search terms
        var ref: DatabaseReference!     //reference to the database
        ref = Database.database().reference()
        
        //get the tag from the search bar
        if let stringvalue = searchBar.text?.lowercased() {
            if(stringvalue.contains(",")){  //ONLY SUPPORTS COMMA-SEPARATED LIST
                searchKeys = stringvalue.components(separatedBy: ",")
            }else{
                searchKeys.append(stringvalue)
            }//searchKeys now contains the user-defined search terms as a comma-separated, lowercase list
        }
        
        //set the totalSearchTerms
        totalSearchTerms = searchKeys.count
        
        for key in searchKeys {  //for each term the user is searching for
            //search the database for that tag
            print("searching DB for: |\(key)|")
            //ref = ref.child("iOS/\(user.username)/photoTags/\(key)")
            let tempRef = ref.child("iOS/photoTags/\(key)")
            tempRef.getData(completion: { (error, snapshot) in
                if let error = error {
                    print("Error getting data for tag: \(key). Error: \(error)")
                } else if !snapshot.exists() {
                    print("At least one of these tags was not found. Please try again")
                    self.presentEmptySearchDialogue()
                } else {
                    //let the callback handle adding the new entries into the combined list
                    print("ids for \(key): \(snapshot.value as! [String])")
                    self.processSearchResults(photoIds: snapshot.value as! [String])
                }
            })
        }
    }
    
    /*
     *  Callback function for searching multiple tags.
     *  this function adds the sent ids to the class-level
     *  search results array as a join, one search term at a time.
     */
    private func processSearchResults(photoIds: [String]){
        searchCounter += 1
        
        //if its the first DB return, add all photos to final collection
        if searchResults.count == 0{
            searchResults = photoIds
        }else{
            //perform join on two arrays, and store the results in searchResults
            searchResults = searchResults.filter(photoIds.contains)
        }
        
        //if that was the last term, segue to the search results view
        if searchCounter == totalSearchTerms{
            //as long as the result list is not empty
            if !searchResults.isEmpty{
                self.segueToSearchResults(photos: searchResults)
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
                photoObjects.append(tempPhoto!)
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
        loadPhotos()
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
        let labeler = MLKitProcess()
        
        labeler.labelAllPhotos(photos: user.photos) {() in
            print("Done processing all photos")
        }
    }
    
    /*
     * Callback function used upon syncing photo object from db to check when all photos have been synced.
     * Needed to know when to start processing all photos since we need to sync if the object has already been
     *      autotagged or not.
     */
    private func doneSyncingPhoto() {
        numPhotosSynced += 1
        if numPhotosSynced == user.photos.count {
            // Done syncing all photos from database
            self.processAllPhotos()
        }
    }
    
    /*
     * Create a list referncing all the local photos the application has access to
     */
    private func loadPhotos() {
        
        // Create a background task
        DispatchQueue.global(qos: .utility).async {
        
            // Create fetch options to return photos in order of creation
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            // Retrieve local photos (photos only, no video)
            let photoResults: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            // Append all images to photos array
            if (photoResults.count > 0) {
                for i in 0..<photoResults.count {
                    self.user.addPhoto(photo: Photo(asset: photoResults[i], callback: self.doneSyncingPhoto))
                }
            } else {
                // Returing array is 0 indcating the application can not view any of the local photos
                print("No Photos were found")
            }
            
            // Callback after retrieveing images is complete
            DispatchQueue.main.async {
                print("Retrieved all local photos")
                
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
        self.user.photos.count
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
    
    /*
     * Segue action prepare statements. Helps send data between view controllers upon a new segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == singlePhotoSegueIdentifier {
            //this assignmnet needs to be in here in the event that we want to segue to settings
            let item = sender as! Photo
            if let viewController = segue.destination as? SinglePhotoViewController {
                viewController.photo = (sender as! Photo)
            }
        }
        else if segue.identifier == searchResultsSegueIdentifier{
            if let viewController = segue.destination as? SearchResultsViewController{
                viewController.photos = sender as! [Photo]
            }
        }
    }
}
