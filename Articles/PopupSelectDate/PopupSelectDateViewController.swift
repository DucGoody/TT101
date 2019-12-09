//
//  PopupSelectDateViewController.swift
//  Articles
//
//  Created by HoangVanDuc on 12/8/19.
//  Copyright © 2019 HoangVanDuc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MonthYearPicker

class PopupSelectDateViewController: UIViewController {

    //control
    @IBOutlet weak var viewControl: UIControl!
    private var viewContentDate: UIView!
    private var datePickerView: UIDatePicker!
    private var btnDoneSelect: UIButton!
    private var picker: MonthYearPickerView!
    
    private let disposeBag = DisposeBag()
    var dateSelected: Date = Date()
    var viewInput: UIView = UIView()
    var onSelectDate:((Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }

    init(dateSelected: Date, viewInput: UIView) {
        super.init(nibName: "PopupSelectDateViewController", bundle: nil)
        self.dateSelected = dateSelected
        self.viewInput = viewInput
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        //viewcontentdate
        let originY = self.viewInput.frame.origin.y + self.viewInput.frame.size.height
        self.viewContentDate = UIView()
        self.viewContentDate.backgroundColor = .white
        self.viewContentDate.layer.cornerRadius = 5
        self.viewControl.addSubview(self.viewContentDate)
        self.viewContentDate.snp.makeConstraints { (view) in
            view.height.equalTo(200)
            view.left.equalTo(self.view).inset(16)
            view.right.equalTo(self.view).inset(16)
            view.top.equalTo(self.view).inset(originY)
        }
        self.addShadow(view: self.viewContentDate)
        
        //button done
        self.btnDoneSelect = UIButton()
        self.btnDoneSelect.setTitle("Xong", for: .normal)
        self.btnDoneSelect.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.btnDoneSelect.setTitleColor(.white, for: .normal)
        self.btnDoneSelect.layer.cornerRadius = 5
        self.btnDoneSelect.backgroundColor = UIColor.link
        
        self.btnDoneSelect.rx.tap.asDriver()
        .throttle(.milliseconds(1000))
        .drive(onNext: { (_) in
            self.actionDoneSelect()
        }).disposed(by: disposeBag)
        self.viewContentDate.addSubview(self.btnDoneSelect)
        self.btnDoneSelect.snp.makeConstraints { (btn) in
            btn.bottom.equalTo(self.viewContentDate).inset(16)
            btn.left.equalTo(self.viewContentDate).inset(16)
            btn.right.equalTo(self.viewContentDate).inset(16)
            btn.height.equalTo(44)
        }
        
        //date picker
        self.picker = MonthYearPickerView.init(frame: CGRect.init(x: 0, y: 0, width: self.viewContentDate.frame.size.width, height: self.viewContentDate.frame.size.height - 66))
                self.viewContentDate.addSubview(self.picker)
                self.picker.snp.makeConstraints { (picker) in
                    picker.top.equalTo(self.viewContentDate).inset(16)
                    picker.left.equalTo(self.viewContentDate).inset(16)
                    picker.right.equalTo(self.viewContentDate).inset(16)
                    picker.bottom.equalTo(self.btnDoneSelect.snp_top).inset(16)
                }
        self.picker.setDate(self.dateSelected, animated: false)
    }
    
    func actionDoneSelect() {
        self.dateSelected = self.picker.date
        self.onSelectDate?(dateSelected)
        self.closePopup()
    }
    
    func closePopup() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 6
    }
    
    @IBAction func actionBackground(_ sender: Any) {
        self.closePopup()
    }
}
