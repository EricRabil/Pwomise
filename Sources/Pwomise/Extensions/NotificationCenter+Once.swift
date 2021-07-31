//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public extension NotificationCenter {
    func once(notificationNamed notificationName: Notification.Name, object: Any? = nil, queue: OperationQueue? = nil) -> Promise<Notification> {
        var observer: NSObjectProtocol!
        
        return Promise { resolve in
            observer = self.addObserver(forName: notificationName, object: object, queue: queue) { notification in
                self.removeObserver(observer!)
                observer = nil
                resolve(notification)
            }
        }
    }
}
