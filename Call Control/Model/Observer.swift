//
//  Observer.swift
//  Call Control
//
//  Created by Kurtis Hill on 2/6/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import Foundation

protocol Observer {
    var id: Int { get }
    func update()
}
