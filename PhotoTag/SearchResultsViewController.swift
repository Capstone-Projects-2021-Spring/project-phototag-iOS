//
//  SearchResultsViewController.swift
//  PhotoTag
//
//  Created by Alex St.Clair on 3/11/21.
//

import UIKit
import Photos

class SearchResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var backButton: UIBarButtonItem!
    
    //re-using these from the main ViewController
    let resultsViewCellNibName = "GalleryCollectionViewCell"
    let resultsViewCellIdentifier = "GalleryItem"
    let singlePhotoSegueIdentifier = "SinglePhotoViewSegue"
    
    var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register and modify the display of individual gallery elements within the gallery collection view
        registerGalleryItemNib()
        viewWillLayoutSubviews()
    }
    
    /*
     * Registers the gallery collection view to use the GalleryItem cell as the primary view cell
     */
    private func registerGalleryItemNib() {
        let nib = UINib(nibName: resultsViewCellNibName, bundle: nil)
        
        // Register galleryItem (photo cell) xib file to the main gallery view
        collectionView.register(nib, forCellWithReuseIdentifier: resultsViewCellIdentifier)
    }
    
    /*
     * Override the default collection view cell look
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureCollectionViewItemSize()
    }
    
    /*
     * Set the size of the individual photo elements within the results collection view
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
        
        collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
    }
    
    //numberOfItemsInSection for collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.photos.count
    }
    
    //cellForItemAt for collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: resultsViewCellIdentifier, for: indexPath) as! GalleryCollectionViewCell
        let photo = photos[indexPath.item]
        
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
     * Collection view function - Handles user selecting an image from the collection view
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        
        performSegue(withIdentifier: self.singlePhotoSegueIdentifier, sender: photo)
    }
}
