//
//  Structs.swift
//  ZichenWang-Lab4
//
//  Created by 王梓辰 on 7/9/20.
//  Copyright © 2020 Zichen Wang. All rights reserved.
//

import Foundation
import UIKit

struct APIResults:Decodable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}
struct Movie: Decodable {
    let id: Int!
    let poster_path: String?
    let title: String
    let release_date: String
    let vote_average: Double
    let overview: String
    let vote_count:Int!
}
