//
//  Photo.swift
//  virtualTourist
//
//  Created by Khaled Kutbi on 06/10/1441 AH.
//  Copyright © 1441 udacity. All rights reserved.
//

import Foundation
import UIKit


class FlickerPhoto: Codable{
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url: String
    let height: Int
    let width: Int
    
    enum codeingKeys: String,CodingKey{
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
        case url = "url_n"
        case height = "height_n"
        case width = "width_n"
        
    }
    
}

