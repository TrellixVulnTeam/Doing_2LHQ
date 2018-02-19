//
//  CreateViewModel.swift
//  Doing
//
//  Created by rotem nevgauker on 1/28/18.
//  Copyright © 2018 rotem nevgauker. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CreateViewModel: NSObject {
    var id:String?
    var fiveWordsTitle:String?
    var text:String?
    var completionDateString:String = CompletionDate.today.rawValue
    var didChangeFiveWordsTitle  = false
    var didChangeText  = false
    var didChangeCompletionDateString = false
    var ref: DatabaseReference = Database.database().reference()
    
    //update date from exsiting task
    func updateModel(task:Task) {
        
        id = task.id
        fiveWordsTitle = task.fiveWordsTitle
        text = task.text
        completionDateString = task.completionDateString
    }
    
    func createTask(completion: @escaping () -> ()) {
        
        if let titleValue = fiveWordsTitle {
            
            if let textValue = text {
                
                    let user_uid = Auth.auth().currentUser?.uid
                    let creationDateStr = Times.todayDateString()
                    let completionDate:String = Times.dateString(dateStr:completionDateString) ?? ""
                    let id = ref.child("posts").childByAutoId().key
                    let task = ["id" : id, "fiveWordsTitle" : titleValue, "text" : textValue, "CreationDate" : creationDateStr, "completionDate": completionDate,"completionDateString": completionDateString] as [String : Any]
                    self.ref.child("users").child(user_uid!).child("tasks").child(id).setValue(task)
            }
        }else {
            print ("error,missing data")
        }
        completion()
    }
    // update the object in the server
    func updatIfNeeded(fiveWordsTitle:String, text:String, completionDateString:String, completion: @escaping () -> ()){
        
            var valuesToUpdate:[String : String] = [String : String]()
            if didChangeFiveWordsTitle {
                valuesToUpdate["fiveWordsTitle"] = fiveWordsTitle
            }
            if didChangeText {
                 valuesToUpdate["text"] = text
            }
            if didChangeCompletionDateString {
                valuesToUpdate["completionDateString"] = completionDateString
                if let date = Times.dateString(dateStr: completionDateString) {
                    valuesToUpdate["completionDate"] = date
                }else {
                     valuesToUpdate["completionDate"] = ""
                }
            }
            
            if valuesToUpdate.count > 0 {
                updateTask(valuesToUpdate: valuesToUpdate, completion: {
                })
            }
            completion()
    }
    
    private func updateTask(valuesToUpdate:[String : String],completion: @escaping () -> ()){
        let user_uid = Auth.auth().currentUser?.uid
        if let taskId = self.id {
             self.ref.child("users").child(user_uid!).child("tasks").child("\(taskId)").updateChildValues(valuesToUpdate)
        }
        completion()
    }
   
}
