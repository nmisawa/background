//
//  BGTaskManager.swift
//  background
//
//  Created by Noriaki Misawa on 2019/09/05.
//  Copyright © 2019 MISAWA.NET All rights reserved.
//

import UIKit
import BackgroundTasks

@available(iOS 13.0, *)
class BGTaskManager: NSObject {

    @objc static let shared = BGTaskManager()

    let apprefresh = "net.misawa.background.apprefresh"

    @objc func registerBackgroundTaks() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: apprefresh, using: nil) { task in

            print("apprefresh")
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
            self.scheduleAppRefresh()
    
        }

    }
    
    @objc func startBackgroundTask() {
        
        scheduleAppRefresh()
        
//        BGTaskScheduler.shared.getPendingTaskRequests { (task) in
//            print(task[0].earliestBeginDate)
//            print(task.count)
//
//        }
        
    }
    
    @objc func taskProcessingCompleted(task: BGProcessingTask) {
        task.setTaskCompleted(success: true)

    }
    
    @objc func taskCompleted(task: BGAppRefreshTask) {
        
        task.setTaskCompleted(success: true)
    
    }
    
    @objc func cancelAllPandingBGTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    @objc func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: apprefresh)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        //Note :: EarliestBeginDate should not be set to too far into the future.
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not nm app refresh: \(error)")
        }
    }
    
    private func handleAppRefreshTask(task: BGAppRefreshTask) {
        //Todo Work
        /*
         //AppRefresh Process
         */
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handleAppRefreshTask"), object: nil, userInfo:["task":task])

        //        scheduleLocalNotification()
        print("handleAppRefreshTask")
        //
        
        task.expirationHandler = {
             print("handle app refresh about to expire");
         }
        
        self.taskCompleted(task: task)
    }


}
