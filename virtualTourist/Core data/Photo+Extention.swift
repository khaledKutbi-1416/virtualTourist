//
//  Photo+Extention.swift
//  virtualTourist
//
//  Created by Khaled Kutbi on 07/10/1441 AH.
//  Copyright © 1441 udacity. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
