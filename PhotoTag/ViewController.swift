//
//  ViewController.swift
//  PhotoTag
//
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Storyboard outlets
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    // Class variables
    let user = User(un: "testUsername")
    
    let galleryViewCellNibName = "GalleryCollectionViewCell"
    let galleryViewCellIdentifier = "GalleryItem"
    let singlePhotoSegueIdentifier = "SinglePhotoViewSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        
        // Register and modify the display of individual gallery elements within the gallery collection view
        registerGalleryItemNib()
        viewWillLayoutSubviews()
        
        getGalleryPermission(callback: postPermissionCheck, failure: failedPermissionCheck)
    }
    
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
        
        labeler.labelPhotos(photos: user.photos) {(lbdPhotos: [Photo]) in
            for lbdPhoto in lbdPhotos {
                print(lbdPhoto.tags)
            }
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
                    self.user.photos.append(Photo(asset: photoResults[i]))
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
                // self.processAllPhotos()
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
        let photo = user.photos[indexPath.item]
        
        cell.imageDisplay.image = photo.getPreviewImage()
        return cell
    }
    
    /*
     * Segue action prepare statements. Helps send data between view controllers upon a new segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let item = sender as! Photo
        
        if segue.identifier == singlePhotoSegueIdentifier {
            if let viewController = segue.destination as? SinglePhotoViewController {
                viewController.photo = item
            }
        }
    }
    
    /*
     * Collection view function - Handles user selecting an image from the gallery view
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        let photo = user.photos[indexPath.item]
        
        performSegue(withIdentifier: self.singlePhotoSegueIdentifier, sender: photo)
    }
}

