//
//  JoinController.swift
//  Pill_Information
//
//  Created by 이준혁 on 2022/06/24.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseAuth
//import FirebaseFirestore

class JoinController: UIViewController, UITextFieldDelegate {
    
    enum CurrentPasswordInputStatus {
        case invaledPassword
        case valedPassword
    }

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPasswordCheck: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblEmailCheck: UILabel!
    @IBOutlet weak var lblPasswordCheck: UILabel!
    
    var emailCheck = false
    var passCheck = false
    var keyHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnNext.isEnabled = false
        initTextField()
        
        lblEmailCheck.text = ""
        lblPasswordCheck.text = ""
        
    }
    
    
    /// 텍스트 필드 초기 설정
    func initTextField() {
        txtEmail.delegate = self
        txtPassword.delegate = self
        txtPasswordCheck.delegate = self
        txtEmail.keyboardType = .emailAddress
        txtPassword.keyboardType = .default
        txtPasswordCheck.keyboardType = .default
        
        txtEmail.text = ""
    }
    
    
    /// 외부 터치 시 키보드 닫기
    /// - Parameters:
    ///   - touches: 터치
    ///   - event: 외부
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.txtEmail.resignFirstResponder()
        self.txtPassword.resignFirstResponder()
        self.txtPasswordCheck.resignFirstResponder()
    }
    
    
    /// Return(Enter) 입력 시 키보드 전환 및 닫기
    /// - Parameter textField: 텍스트필드
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail {
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            txtPasswordCheck.becomeFirstResponder()
        } else {
            txtPasswordCheck.resignFirstResponder()
            signUp(btnNext)
        }
        return true
    }
    
    
    /// 텍스트필드 형식 검사 함수
    /// - Parameters:
    ///   - str: 검사할 문자열
    ///   - textField: 검사할 문자열이 담긴 텍스트 필드(이에 따라 검사 방법이 달라짐)
    /// - Returns: 형식이 알맞은지 true, false로 반환함.
    func isValid(str: String, textField:UITextField) -> Bool {
        if textField == txtEmail {  // 이메일 형식
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: str)
        } else {    // 비밀번호 형식 (숫자, 문자 포함 8자 이상)
            let passwordRegEx = "^[a-zA-Z0-9]{8,}$"
            let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
            return passwordTest.evaluate(with: str)
        }
    }
    
    
    /// 다음 버튼
    ///  이메일과 비밀번호를 확인한 뒤 버튼이 활성화 됨.
    /// - Parameter sender: 다음 버튼
    @IBAction func signUp(_ sender: UIButton) {
        if txtPassword.text != txtPasswordCheck.text {
            messageAlert(controllerTitle: "경고", controllerMessage: "비밀번호가 일치하지 않습니다.", actionTitle: "확인")
        } else {
            // 유저 생성
            Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { [self]authResult, error in
                
    //            let uid = authResult?.user.uid
                if let _ = error { // 유저 생성에 실패할 경우
                    self.messageAlert(controllerTitle: "회원가입 실패", controllerMessage: "중복된 이메일/핸드폰 번호입니다.", actionTitle: "확인")
                } else { // 유저 생성에 성공할 경우
                    let alertCon = UIAlertController(title: "회원가입 성공", message: "회원가입에 성공하였습니다.", preferredStyle: UIAlertController.Style.alert)
                    let alertAct = UIAlertAction(title: "로그인", style: UIAlertAction.Style.default, handler:  { (action) in
                        self.changeView(viewName: "emailLoginView") })
                    alertCon.addAction(alertAct)
                    present(alertCon, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func btnBack(_ sender: UIButton) {
        changeView(viewName: "emailLoginView")
    }
    
    /// 모든 텍스트필드의 공백을 검사, 이메일 형식, 비밀번호 형식 검사
    /// 위 경우를 모두 만족할 경우 btnNext 활성화
    /// - Parameter textField: 입력하고 있는 TextField
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == txtEmail {
            emailCheck = isValid(str: txtEmail.text ?? "", textField: txtEmail)
            if emailCheck == false {
                lblEmailCheck.text = "이메일 형식에 맞추어 주십시오."
            } else {
                lblEmailCheck.text = ""
            }
        } else {
            if txtPassword.text != txtPasswordCheck.text {
                lblPasswordCheck.text = "비밀번호가 일치하지 않습니다."
            } else if !isValid(str: txtPasswordCheck.text ?? "", textField: txtPasswordCheck) {
                lblPasswordCheck.text = "소문자, 대문자, 숫자를 조합하여 8자 이상"
            } else {
                lblPasswordCheck.text = ""
            }
        }
        
        if txtEmail.text == "" || txtPassword.text == "" || txtPasswordCheck.text == "" ||
            emailCheck == false || passCheck == false {
            btnNext.isEnabled = false
        } else {
            btnNext.isEnabled = true
        }
    }
    
    
    /// Alert 출력
    /// - Parameters:
    ///   - controllerTitle: Alert Title
    ///   - controllerMessage: Alert Message
    ///   - actionTitle: action(button content)
    func messageAlert(controllerTitle:String, controllerMessage:String, actionTitle:String) {
        let alertCon = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: UIAlertController.Style.alert)
        let alertAct = UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default)
        alertCon.addAction(alertAct)
        present(alertCon, animated: true, completion: nil)
    }
    
    
    /// 화면 전환 함수
    /// - Parameter viewName: 어떤 화면을 전환할지 정할 문자열
    func changeView(viewName: String) {
        if viewName == "emailLoginView" {
            guard let vcName = self.storyboard?.instantiateViewController(withIdentifier: "EmailLoginBoard")as? EmailLoginController else {return}
            
            vcName.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            vcName.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            self.present(vcName, animated: true, completion: nil)
        }
    }
}
