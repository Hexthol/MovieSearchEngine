//
//  FavouriteViewController.swift
//  ZichenWang-Lab4
//
//  Created by 王梓辰 on 7/15/20.
//  Copyright © 2020 Zichen Wang. All rights reserved.
//

import UIKit
import NaturalLanguage

class FavouriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var favMovies:Array<String> = []
    var favDicts:Dictionary<String, Int> = [:]
    var favMoviesBackup:Array<String> = []
    var spinner : UIActivityIndicatorView = UIActivityIndicatorView()
    var theMovie:Movie?
    var state:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        setupSpinner()
        if UserDefaults.standard.dictionary(forKey: "favDicts") != nil {
            favDicts = UserDefaults.standard.dictionary(forKey: "favDicts") as! Dictionary<String, Int>
        }else{
            favDicts = [:]
        }
        if UserDefaults.standard.object(forKey: "favMovies") != nil {
            favMovies = UserDefaults.standard.array(forKey: "favMovies") as! Array<String>
        }else{
            favMovies = []
        }
        
        favMoviesBackup = favMovies
        tableView.reloadData()
    }
    
    func setupSpinner(){
        spinner.color = .black
        spinner.hidesWhenStopped = true
        spinner.center = self.view.center
        spinner.style = UIActivityIndicatorView.Style.large
        view.addSubview(spinner)
    }
    
    //Creative Portion of sort favorites by different standard
    func sortAction(action:UIAlertAction!){
        switch action.title! {
        case "Time Added":
            if UserDefaults.standard.dictionary(forKey: "favDicts") != nil {
                favDicts = UserDefaults.standard.dictionary(forKey: "favDicts") as! Dictionary<String, Int>
            }else{
                favDicts = [:]
            }
            if UserDefaults.standard.object(forKey: "favMovies") != nil {
                favMovies = UserDefaults.standard.array(forKey: "favMovies") as! Array<String>
            }else{
                favMovies = []
            }

            state=true
            tableView.reloadData()
            break
        case "Alphabetically":
            let sortedMovies = favMovies.sorted()
            favMovies = sortedMovies
            tableView.reloadData()
            state = false
            break
        default:
            break
        }
    }
    
    @IBAction func sortTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Sort Favorite Movies By...", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Time Added", style: .default, handler: sortAction(action:)))
        ac.addAction(UIAlertAction(title: "Alphabetically", style: .default, handler: sortAction(action:)))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "favMovies") != nil {
            favMoviesBackup = UserDefaults.standard.array(forKey: "favMovies") as! Array<String>
        }else{
            favMoviesBackup = []
        }
        
        if state{
            if UserDefaults.standard.object(forKey: "favMovies") != nil {
                favMovies = UserDefaults.standard.array(forKey: "favMovies") as! Array<String>
            }else{
                favMovies = []
            }
            if UserDefaults.standard.dictionary(forKey: "favDicts") != nil {
                favDicts = UserDefaults.standard.dictionary(forKey: "favDicts") as! Dictionary<String, Int>
            }else{
                favDicts = [:]
            }
            tableView.reloadData()
        }
        else{
            let sortedMovies = favMovies.sorted()
            favMovies = sortedMovies
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theCell = UITableViewCell(style: .default, reuseIdentifier: "theCell")
        theCell.textLabel!.text = favMovies[indexPath.row]
        return theCell
    }
    
    //Learnt from https://www.ioscreator.com/tutorials/delete-rows-table-view-ios-tutorial-ios12
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            favDicts[favMovies[indexPath.row]] = nil
            favMovies.remove(at: indexPath.row)
            for index in 0 ..< favMoviesBackup.count {
                if favDicts[favMoviesBackup[index]] == nil {
                    favMoviesBackup.remove(at: index)
                    break
                }
            }
            UserDefaults.standard.set(favMoviesBackup, forKey: "favMovies")
            UserDefaults.standard.set(favDicts, forKey: "favDicts")
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    
    //Creative Portion of displaying detailedview when selecting films in favorites
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var image : UIImage!
        theMovie = nil
        self.spinner.startAnimating()
        DispatchQueue.global().async {
            self.fetchData(movieTitle: self.favMovies[indexPath.row], movieId: self.favDicts[self.favMovies[indexPath.row]]!)
            if self.theMovie != nil{
                do{
                    let url = URL(string:"https://image.tmdb.org/t/p/w500/\(self.theMovie!.poster_path!)" )
                    let data = try Data(contentsOf: url!)
                    image = UIImage(data: data)
                }
                catch{
                    image = UIImage(named: "DNE")
                }
                DispatchQueue.main.async {
                    let DetailedVC = DetailedViewController()
                    self.navigationController?.pushViewController(DetailedVC, animated: true)
                    DetailedVC.movie = self.theMovie
                    DetailedVC.image = image
                    self.spinner.stopAnimating()
                }
            }
            else{
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Unsupported Language", message: "Sorry, we cuurently cannot make API query in other languages except English", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.spinner.stopAnimating()
                }
            }
        }
        
    }
    
    func fetchData(movieTitle : String, movieId:Int){
        let movieName = movieTitle.replacingOccurrences(of: " ", with: "%20")
        if detectedLanguage(for: movieName) != "English"{
            theMovie = nil
            return
        }
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=20c2064398b89759700d495837448bfa&query=\(movieName)&include_adult=true"
        let url = URL(string: urlString)!
        guard let data = try? Data(contentsOf: url) else{
            return
        }
        do{
            let outcome = try JSONDecoder().decode(APIResults.self, from: data)
            for i in outcome.results{
                if i.id == movieId{
                    theMovie = i
                }
            }
        }
        catch{
            theMovie = nil
        }
    }
    
    //Credit to highest voted anwser from https://stackoverflow.com/questions/47890747/how-to-detect-text-string-language-in-ios
    func detectedLanguage(for string: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(string)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        let detectedLanguage = Locale.current.localizedString(forIdentifier: languageCode)
        return detectedLanguage
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
