//
//  RankViewController.swift
//  HackAthon
//
//  Created by haruhito on 2017/05/21.
//  Copyright © 2017年 FromF. All rights reserved.
//

import UIKit
import SafariServices

class RankViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SFSafariViewControllerDelegate {

    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var levelButton: NSLayoutConstraint!
    @IBOutlet weak var registButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let categoryArray = ["HTML","CSS","Swift","Ruby"]
    let levelArray = ["初級","中級","上級"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // リストを初期化
        self.searchResultArray.removeAll()
        search(keyword: "詳解Swift")
        search(keyword: "絶対に挫折しない iPhoneアプリ開発「超」入門 ")
        search(keyword: "Swift実践入門")
        search(keyword: "これからつくる iPhoneアプリ開発入門")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func categoryButtonAction(_ sender: Any) {
        showSelectButton(title: "ジャンル" , selectStringArray: categoryArray, completionHandler: {(title) -> Void in
            let button = sender as! UIButton
            button.setTitle(title, for: .normal)
        })
    }
    
    @IBAction func levelButtonAction(_ sender: Any) {
        showSelectButton(title: "レベル",selectStringArray: levelArray, completionHandler: {(title) -> Void in
            let button = sender as! UIButton
            button.setTitle(title, for: .normal)
        })
    }
    
    @IBAction func registButtonAction(_ sender: Any) {
        
    }

    // MARK: - UITableViewDelegate
    // Cellの総数を返すdatasourceメソッド、必ず記述する必要があります
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // リストの総数
        return searchResultArray.count
    }
    
    // Cellに値を設定するdatasourceメソッド。必ず記述する必要があります
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //今回表示を行う、Cellオブジェクト（１行）を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RankTableViewCell
        
        let number = indexPath.row
        
        cell.numberLabel.text = "\(number + 1)"
        cell.titleTextView.text = searchResultArray[number].titile
        cell.authorLabel.text = searchResultArray[number].author
        
        // お菓子画像のURLを取り出す
        let url = URL(string: searchResultArray[number].thumnail)
        
        // URLから画像を取得
        if let image_data = try? Data(contentsOf: url!) {
            // 正常に取得できた場合は、UIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
            cell.bookCoverImage.image = UIImage(data: image_data)
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

    // MARK: - SFSafariViewControllerDelegate
    // SafariViewが閉じられた時に呼ばれるdelegateメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // SafariViewを閉じる
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - 選択肢を表示する機能
    func showSelectButton(title:String , selectStringArray:[String] , completionHandler: @escaping ((String) -> Void)) {
        let alertController = UIAlertController(title: title, message: "選択してください", preferredStyle: .actionSheet)

        for selectString in selectStringArray {
            let cameraAction = UIAlertAction(title: selectString, style: .default, handler:  { (action:UIAlertAction) in
                //
                completionHandler(selectString)
            })
            alertController.addAction(cameraAction)
        }
        
        // キャンセルの選択肢を定義
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // iPadで落ちてしまう対策
        alertController.popoverPresentationController?.sourceView = view
        
        // 選択肢を画面に表示
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - 検索処理
    let searchAPI = "https://www.googleapis.com/books/v1/volumes?q="
    /// 検索結果リスト（タプル配列）
    var searchResultArray : [(titile:String , author:String , thumnail:String , link:String)] = []
    // Searchメソッド
    // 第一引数：keyword 検索したいワード
    func search(keyword : String) {
        //検索キーワードをURLエンコードする
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
                
                
                // 情報が取得できているか確認
                if let items = json["items"] as? [[String:Any]] {
                    
                    // 取得している数だけ処理
                    for item in items {
                        // title
                        guard let volumeInfo = item["volumeInfo"] as? [String:Any] else {
                            continue
                        }
                        guard let title = volumeInfo["title"] as? String else {
                            continue
                        }
                        //authors
                        guard let authors = volumeInfo["authors"] as? [String] else {
                            continue
                        }
                        var author = ""
                        for author_ in authors {
                            author += " \(author_)"
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
                        let data = (title,author,thumnail,link)
                        // お菓子の配列へ追加
                        self.searchResultArray.append(data)
                        if self.searchResultArray.count > 0 {
                            break
                        }
                    }
                }
                
                print ("----------------")
                for result in self.searchResultArray {
                    print ("searchResultArray = \(result)")
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
