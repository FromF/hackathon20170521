//
//  ViewController.swift
//  BookSearch
//
//  Created by haruhito on 2017/05/21.
//  Copyright © 2017年 FromF. All rights reserved.
//

import UIKit
import SafariServices


class ViewController: UIViewController , UITextFieldDelegate , UITableViewDelegate , UITableViewDataSource ,SFSafariViewControllerDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchAPI = "https://www.googleapis.com/books/v1/volumes?q="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self

        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate
    
    // 改行ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 検索する
        search(keyword: textField.text!)
        
        // キーボードを隠す
        textField.resignFirstResponder()
        return true
    }
    
    // クリアボタンが押された時の処理
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        print("Clear")
        return true
    }
    
    // テキストフィールドがフォーカスされた時の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("Start")
        return true
    }
    
    // テキストフィールドでの編集が終わろうとするときの処理
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("End")
        return true
    }

    
    // MARK: - UITableViewDelegate
    // Cellの総数を返すdatasourceメソッド、必ず記述する必要があります
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // お菓子リストの総数
        return searchResultArray.count
    }
    
    // Cellに値を設定するdatasourceメソッド。必ず記述する必要があります
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //今回表示を行う、Cellオブジェクト（１行）を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // お菓子のタイトル設定
        cell.textLabel?.text = searchResultArray[indexPath.row].titile
        
        // お菓子画像のURLを取り出す
        let url = URL(string: searchResultArray[indexPath.row].thumnail)
        
        // URLから画像を取得
        if let image_data = try? Data(contentsOf: url!) {
            // 正常に取得できた場合は、UIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
            cell.imageView?.image = UIImage(data: image_data)
        }
        
        // 設定済みのCellオブジェクトを画面に反映
        return cell
    }
    
    // Cellが選択された際に呼び出されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        // URLをstring → URL型に変換
        let urlToLink = URL(string: searchResultArray[indexPath.row].link)
        
        // SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: urlToLink!)
        
        // delegateの通知先を自分自身
        safariViewController.delegate = self
        
        // SafariViewが開かれる
        present(safariViewController, animated: true, completion: nil)
    }
    
    // SafariViewが閉じられた時に呼ばれるdelegateメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // SafariViewを閉じる
        dismiss(animated: true, completion: nil)
    }

    
    
    // MARK: - 検索処理
    /// 検索結果リスト（タプル配列）
    var searchResultArray : [(titile:String , thumnail:String , link:String)] = []
    // Searchメソッド
    // 第一引数：keyword 検索したいワード
    func search(keyword : String) {
        //お菓子の検索キーワードをURLエンコードする
        let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // URLオブジェクトの生成
        let url = URL(string: "\(searchAPI)\(keyword_encode!)")!
        let req = URLRequest(url: url)
        
        // セッション情報を取り出し
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        // リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data , request , error) in
            // do try catch エラーハンドリング
            do {
                // 受け取ったJSONデータをパース（解析）して格納します
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                
                // お菓子のリストを初期化
                self.searchResultArray.removeAll()
                
                // お菓子の情報が取得できているか確認
                if let items = json["items"] as? [[String:Any]] {
                    
                    // 取得しているお菓子の数だけ処理
                    for item in items {
                        // title
                        guard let volumeInfo = item["volumeInfo"] as? [String:Any] else {
                            continue
                        }
                        guard let title = volumeInfo["title"] as? String else {
                            continue
                        }
                        // thumnail
                        guard let imageLinks = volumeInfo["imageLinks"] as? [String:Any] else {
                            continue
                        }
                        guard let thumnail = imageLinks["thumbnail"] as? String else {
                            continue
                        }
                        // link
                        guard let saleInfo = item["saleInfo"] as? [String:Any] else {
                            continue
                        }
                        guard let link = saleInfo["buyLink"] as? String else {
                            continue
                        }
                        // １件の検索結果をタプルでまとめて管理
                        let data = (title,thumnail,link)
                        // お菓子の配列へ追加
                        self.searchResultArray.append(data)
                    }
                }
                
                print ("----------------")
                if let result = self.searchResultArray.first {
                    print ("okashiList[0] = \(result)")
                }
                print ("----------------")
                
                //Table Viewを更新する
                self.tableView.reloadData()
                
            } catch {
                // エラー処理
                print("エラーが出ました")
            }
        })
        // ダウンロード開始
        task.resume()
    }

}

