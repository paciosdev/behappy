//
//  CIImage+Extension.swift
//  BeHappy
//
//  Created by Francesco Paciello on 12/11/24.
//

import CoreImage

extension CIImage {
    
    var cgImage: CGImage? {
        let ciContext = CIContext()
        
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else {
            return nil
        }
        
        return cgImage
    }
    
}
