//
//  ViewController.swift
//  PDFGenerationFromTableView
//
//  Created by Javid Museyibli on 18.10.21.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(generatePDF))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sampleCell")
    }

    @objc func generatePDF() {
        tableView.savePDFFromScreenshot(with: "PDFDocument")
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 41
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sampleCell")!
        cell.textLabel?.text = "Cell #\(indexPath.row)"
        return cell
    }
}

fileprivate extension UIScrollView {
    func screenshot() -> UIImage? {
        var image = UIImage();
            UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)

            // save initial values
            let savedContentOffset = contentOffset
            let savedBackgroundColor = backgroundColor
            // save superview
            let savedSuperView = superview
            let savedConstraints = savedSuperView!.constraints

            // reset offset to top left point
            contentOffset = CGPoint(x: 0, y: 0)
            // set frame to content size
            frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height);
            // remove background
            backgroundColor = UIColor.clear

            // make temp view with scroll view content size
            // a workaround for issue when image on ipad was drawn incorrectly
            let tempView = UIView(frame: CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height));

            // remove scrollView from old superview
            removeFromSuperview()
            // and add to tempView
            tempView.addSubview(self)

            // render view
            // drawViewHierarchyInRect not working correctly
            tempView.layer.render(in: UIGraphicsGetCurrentContext()!)
            // and get image
            image = UIGraphicsGetImageFromCurrentImageContext()!;

            // and return everything back
            tempView.subviews[0].removeFromSuperview()
            savedSuperView?.addSubview(self)
            NSLayoutConstraint.activate(savedConstraints)

            // restore saved settings
            contentOffset = savedContentOffset;
            // tableView.frame = savedFrame;
            backgroundColor = savedBackgroundColor

            UIGraphicsEndImageContext();
            return image
    }

    func generatePDFFromScreenshot() -> Data? {
        let pdfDocument = PDFDocument()
        let image = screenshot()
        let pdfPage = PDFPage(image: image!)
        pdfDocument.insert(pdfPage!, at: 0)
        return pdfDocument.dataRepresentation()
    }

    func savePDFFromScreenshot(with filename: String) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentDirectory.appendingPathComponent("\(filename).pdf")
        let data = generatePDFFromScreenshot()
        try! data!.write(to: url)
    }

}
