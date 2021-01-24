//
//  DetailedViewController.swift
//  ZichenWang-Lab4
//
//  Created by 王梓辰 on 7/15/20.
//  Copyright © 2020 Zichen Wang. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController {
    
    var movie : Movie!
    var image : UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = movie.title
        view.backgroundColor = .white
        
        //Code similar to Lab4 Demo code
        let theImageFrame = CGRect(x: view.frame.midX - image.size.width/4, y: 80, width: image.size.width/2, height: image.size.height/2)
        let imageView = UIImageView(frame: theImageFrame)
        imageView.image = image
        view.addSubview(imageView)
        
        
        let theDateFrame = CGRect(x: 0, y: image.size.height/2 + 100, width: view.frame.width, height: 30)
        let dateView = UITextView(frame: theDateFrame)
        dateView.text = "Release Date: \(movie.release_date)"
        dateView.textAlignment = .center
        view.addSubview(dateView)
        
        let theVoteFrame = CGRect(x: 0, y: image.size.height/2 + 130, width: view.frame.width, height: 30)
        let voteView = UITextView(frame: theVoteFrame)
        voteView.text = "Voted Average: \(movie.vote_average)"
        voteView.textAlignment = .center
        view.addSubview(voteView)
        
        let theOverviewFrame = CGRect(x: 0, y: image.size.height/2 + 160, width: view.frame.width, height: 150)
        let overView = UITextView(frame: theOverviewFrame)
        overView.text = "Overview: \(movie.overview)"
        overView.textAlignment = .center
        view.addSubview(overView)
        
        
        let theButtonFrame = CGRect(x: view.frame.midX - view.frame.width/6, y: image.size.height/2 + 310, width: view.frame.width/3, height: 30)
        let button = UIButton(frame: theButtonFrame)
        button.backgroundColor = .black
        button.setTitle("Add to Favorite", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
    }
    
    //Learn to add @objc prefix from https://stackoverflow.com/questions/24102191/make-a-uibutton-programmatically-in-swift/40350949
    @objc func buttonAction(sender: UIButton!) {
        
        if UserDefaults.standard.dictionary(forKey: "favDicts") == nil {
            var favDicts:Dictionary<String, Int> = [:]
            favDicts[movie.title] = movie.id
            UserDefaults.standard.set(favDicts, forKey: "favDicts")
        }
        else{
            var favDicts = UserDefaults.standard.dictionary(forKey: "favDicts") as! Dictionary<String, Int>
            if favDicts[movie.title] == nil{
                favDicts[movie.title] = movie.id
                UserDefaults.standard.set(favDicts, forKey: "favDicts")
            }
        }
        
        if UserDefaults.standard.array(forKey: "favMovies") == nil{
            var favMovies : Array<String> = []
            favMovies.append(movie.title)
            UserDefaults.standard.set(favMovies, forKey: "favMovies")
        }
        else{
            var favMovies = UserDefaults.standard.array(forKey: "favMovies") as! Array<String>
            if !favMovies.contains(movie.title) {
                favMovies.append(movie.title)
                UserDefaults.standard.set(favMovies, forKey: "favMovies")
            }
        }
           
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
