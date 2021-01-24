//
//  ViewController.swift
//  ZichenWang-Lab4
//
//  Created by 王梓辰 on 7/9/20.
//  Copyright © 2020 Zichen Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scoreSlider: UISlider!
    @IBOutlet weak var score: UILabel!
    
    var movies:[Movie] = []
    var posters:[UIImage] = []
    var spinner:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var requiredScore:Double = 0.0
    var adult:Bool = false
    var lang:String = "en"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCollectionView()
        searchBar.delegate = self
        setupSpinner()
    }
    
    func setupSpinner(){
        spinner.color = .black
        spinner.hidesWhenStopped = true
        spinner.center = self.view.center
        spinner.style = UIActivityIndicatorView.Style.large
        view.addSubview(spinner)
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let theCell = collectionView.dequeueReusableCell(withReuseIdentifier: "theCell", for: indexPath) as! CustomCollectionViewCell
        theCell.theImageView.image = posters[indexPath.row]
        theCell.theTextView.text = movies[indexPath.row].title
        return theCell
    }
    
    //Extra Credit Code
    //Credit to https://kylebashour.com/posts/ios-13-context-menus
    func collectionView(_ collectionView: UICollectionView,contextMenuConfigurationForItemAt indexPath: IndexPath,point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu(for:self.movies[indexPath.row])
        }
    }
    
    //Context Menu Action
    func createContextMenu(for theMovie:Movie) -> UIMenu {
        let favorite = UIAction(title: "Favorite", image: UIImage(systemName: "heart.fill")) { _ in
            print("Favorite")
            if UserDefaults.standard.dictionary(forKey: "favDicts") == nil {
                var favDicts:Dictionary<String, Int> = [:]
                favDicts[theMovie.title] = theMovie.id
                UserDefaults.standard.set(favDicts, forKey: "favDicts")
            }
            else{
                var favDicts = UserDefaults.standard.dictionary(forKey: "favDicts") as! Dictionary<String, Int>
                if favDicts[theMovie.title] == nil{
                    favDicts[theMovie.title] = theMovie.id
                    UserDefaults.standard.set(favDicts, forKey: "favDicts")
                }
            }
            
            if UserDefaults.standard.array(forKey: "favMovies") == nil{
                var favMovies : Array<String> = []
                favMovies.append(theMovie.title)
                UserDefaults.standard.set(favMovies, forKey: "favMovies")
            }
            else{
                var favMovies = UserDefaults.standard.array(forKey: "favMovies") as! Array<String>
                if !favMovies.contains(theMovie.title) {
                    favMovies.append(theMovie.title)
                    UserDefaults.standard.set(favMovies, forKey: "favMovies")
                }
            }
        }
        return UIMenu(title: "", children: [favorite])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var image : UIImage!
        self.spinner.startAnimating()
        DispatchQueue.global().async {
            do{
                let url = URL(string:"https://image.tmdb.org/t/p/w500/\(self.movies[indexPath.row].poster_path!)" )
                let data = try Data(contentsOf: url!)
                image = UIImage(data: data)
            }
            catch{
                image = UIImage(named: "DNE")
            }
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                let DetailedVC = DetailedViewController()
                self.navigationController?.pushViewController(DetailedVC, animated: true)
                DetailedVC.movie = self.movies[indexPath.row]
                DetailedVC.image = image
            }
        }
    }
    
    
    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Learn to set up collectview layout from https://www.raywenderlich.com/9334-uicollectionview-tutorial-getting-started#
        let cellSize = UIScreen.main.bounds.width / 3 - 10
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: cellSize, height: cellSize * 3/2)
        collectionView.collectionViewLayout = layout
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let movieName = searchBar.text else {
            return
        }
        self.spinner.startAnimating()
        DispatchQueue.global().async {
            self.movies = []
            self.posters = []
            self.fetchData(movieTitle: movieName)
            self.cacheImage()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.spinner.stopAnimating()
            }
        }
    }
    
    //Creative Portion of filtering
    @IBAction func filterCahnged(_ sender: Any) {
        requiredScore = Double(scoreSlider.value)
        let value = scoreSlider.value
        let displayText = "\(String(format: "%.1f", value))"
        score.text = "\(displayText)"
    }
    
    
    func fetchData(movieTitle : String){
        if UserDefaults.standard.object(forKey: "adult") != nil {
            adult = UserDefaults.standard.bool(forKey: "adult")
        }
        if UserDefaults.standard.object(forKey: "lang") != nil {
            lang = UserDefaults.standard.string(forKey: "lang")!
        }
        
        let movieName = movieTitle.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=20c2064398b89759700d495837448bfa&query=\(movieName)&language=\(lang)&include_adult=\(adult)"
        let url = URL(string: urlString)!
        guard let data = try? Data(contentsOf: url) else{
            return
        }
        do{
            let outcome = try JSONDecoder().decode(APIResults.self, from: data)
            for i in outcome.results{
                //filter by score
                if i.poster_path != nil && i.vote_average >= requiredScore{
                    movies.append(i)
                }
            }
        }
        catch{
            movies = []
        }
    }
    
    func cacheImage(){
        for i in movies {
            do {
                let url = URL(string:"https://image.tmdb.org/t/p/w200/\(i.poster_path!)" )
                let data = try Data(contentsOf: url!)
                let image = UIImage(data:data)
                posters.append(image!)
            }catch{
                posters.append(UIImage(named: "DNE")!)
            }
        }
    }
}

