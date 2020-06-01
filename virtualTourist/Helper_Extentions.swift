//
//  Helper_Extentions.swift
//  VirtualTourist
//
//  Created by Khaled Kutbi on 09/10/1441 AH.
//  Copyright © 1441 Andrey Valverde Solera. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func showALert(title : String , message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

