

import UIKit
import CoreData

// Global Variables
let appDelegate = UIApplication.shared.delegate as? AppDelegate

class ViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var TF_firstname: UITextField!
    @IBOutlet weak var TF_lastname: UITextField!
    @IBOutlet weak var BTN_saveUser : UIButton!
    
    @IBOutlet weak var dataTable : UITableView!
    
    var userArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callDelegates()
        UIconfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Datafetch()
    }
    @IBAction func saveUser_BtnAction(_ sender: Any) {
        saveUser(completion: { (done) in
            if done {
                TF_firstname.text = ""
                TF_lastname.text = ""
                 Datafetch()
            } else {
                print("Try again")
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(true)
    }
}

extension ViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableviewCell")as! TableviewCell
        let newuser = userArray[indexPath.row]
        
        cell.lbl_firstName.text = newuser.firstname
        cell.lbl_lastName.text = newuser.lastname
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteData(indexPath: indexPath)
            self.Datafetch()
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        return [deleteAction]
    }
}


extension ViewController {
    //TABLE DELEGATE FUNCTION CALLING
    func callDelegates(){
        dataTable.delegate = self as? UITableViewDelegate
        dataTable.dataSource = self
        dataTable.isHidden = true
    }
    //TEXT FIELD SETUP
    func UIconfig(){
        self.TF_lastname.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.TF_firstname.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.TF_firstname.layer.borderWidth = 1
        self.TF_lastname.layer.borderWidth = 1
        self.TF_lastname.layer.cornerRadius = 5
        self.TF_firstname.layer.cornerRadius = 5
        self.BTN_saveUser.layer.cornerRadius = 5
        self.BTN_saveUser.layer.borderWidth = 1
        self.BTN_saveUser.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.dataTable.layer.cornerRadius = 10
        self.dataTable.layer.borderWidth = 1
        self.dataTable.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    //PREPARED DATA FETCH INTO TABLEVIEW
    func Datafetch(){
        fetchData ( completion: { (done) in
            if done {
                if userArray.count > 0 {
                    dataTable.isHidden = false
                } else {
                    dataTable.isHidden = true
                }
            }
        })

    }
    //DATA SAVE TO LOCAL DATABASE
    func saveUser(completion: (_ finished: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let user = User(context: managedContext)
        user.firstname = TF_firstname.text
        user.lastname = TF_lastname.text
        user.taskstatus = false
        
        do {
            try managedContext.save()
            print("Data Saved")
            completion(true)
        } catch {
            print("Failed to save data: ", error.localizedDescription)
            completion(false)
        }
    }
    
    //SAVED DATA FETCHING INTO TABLEVIEW
    func fetchData(completion: (_ complete: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            userArray = try  managedContext.fetch(request) as! [User]
            print("Data fetched, no issues")
            completion(true)
        } catch {
            print("Unable to fetch data: ", error.localizedDescription)
            completion(false)
        }
        self.dataTable.reloadData()
    }
    
    //DELETE FETCHED DATA FROM TABLEVIEW
    func deleteData(indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(userArray[indexPath.row])
        do {
            try managedContext.save()
            print("Data Deleted")
        } catch {
            print("Failed to delete data: ", error.localizedDescription)
        }
    }
}


class TableviewCell : UITableViewCell{
    @IBOutlet weak var lbl_firstName : UILabel!
    @IBOutlet weak var lbl_lastName : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lbl_firstName.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.lbl_lastName.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.lbl_firstName.layer.borderWidth = 1
        self.lbl_lastName.layer.borderWidth = 1
        self.lbl_firstName.layer.cornerRadius = 5
        self.lbl_lastName.layer.cornerRadius = 5 
    }
}
