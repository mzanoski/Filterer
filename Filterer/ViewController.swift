//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let appContext = ApplicationContext.Context
    var lastSelectedButtonTag: Int?
    var lastSelectedFilterButton: UIButton?
    var oldSliderValue: Float = 0
    
    @IBOutlet weak var originalLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var sliderMidpointLine: UIImageView!
    @IBOutlet var filterEditMenuSlider: UISlider!
    @IBOutlet var filterEditMenu: UIView!
    
    @IBOutlet weak var bwFilterButton: UIButton!
    @IBOutlet weak var negativeFilterButton: UIButton!
    @IBOutlet weak var contrastFilterButton: UIButton!
    @IBOutlet weak var brightnessFilterButton: UIButton!
    @IBOutlet weak var channelFilterButton: UIButton!
    @IBOutlet var secondaryMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet var bottomMenu: UIView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        filterEditMenu.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        filterEditMenu.translatesAutoresizingMaskIntoConstraints = false

        self.imageView.userInteractionEnabled = true
        self.originalLabel.layer.borderColor = UIColor.whiteColor().CGColor
        self.originalLabel.layer.borderWidth = 2.0
        self.originalLabel.layer.cornerRadius = 8.0
        
        appContext.addToButtonFilterMap(1, filterName: "Grayscale")
        appContext.addToButtonFilterMap(2, filterName: "Brightness")
        appContext.addToButtonFilterMap(3, filterName: "Contrast")
        appContext.addToButtonFilterMap(4, filterName: "Sparticles")
        appContext.addToButtonFilterMap(5, filterName: "Negative")
        
        
        if let image = imageView.image{
            appContext.setImageForFiltering(image)
        }
    }
    
    // MARK: Crossfade Image
    func crossFadeImageViewToImage(newImage: UIImage?){
        UIView.transitionWithView(self.imageView, duration:0.4, options: .TransitionCrossDissolve, animations: {
                self.imageView.image = newImage
            },
        completion: nil)
    }
    
    // MARK: Compare
    func showOriginalImage(){
        crossFadeImageViewToImage(appContext.originalImage)
        self.originalLabel.hidden = false
        compareButton.selected = true
        
        disableFilterButtons()
        disableFilterEditMenuControls()
    }
    
    func showFilteredImage(){
        if appContext.filteredImage != nil {
            crossFadeImageViewToImage(appContext.filteredImage)
        }
        else {
            crossFadeImageViewToImage(appContext.originalImage)
        }
        self.originalLabel.hidden = true
        compareButton.selected = false
        
        enableFilterButtons()
        enableFilterEditMenuControls()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first?.view == self.imageView && (!self.compareButton.selected && appContext.hasFilteredImage){
            showOriginalImage()
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first?.view == self.imageView && appContext.hasFilteredImage{
            showFilteredImage()
        }
    }
    
    @IBAction func onCompare(sender: UIButton) {
        if sender.selected {
            showFilteredImage()
        }
        else {
            showOriginalImage()
        }
    }

    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setImageToBeFiltered(image)
            
            if filterButton.selected {
                hideSecondaryMenu()
            }
            
            if editButton.selected {
                hideFilterEditMenu()
            }

            editButton.selected = false
            compareButton.selected = false
            compareButton.enabled = false
            originalLabel.hidden = true
        }
    }
    
    func setImageToBeFiltered(image: UIImage){
        appContext.setImageForFiltering(image)
        showFilteredImage()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menus
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideFilterEditMenu()
            hideSecondaryMenu()
        } else {
            showSecondaryMenu()
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
        filterButton.selected = true
        
    }

    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
        filterButton.selected = false
    }

    @IBAction func onEditMenu(sender: UIButton) {
        if (sender.selected) {
            hideFilterEditMenu()
            sender.selected = false
        } else {
            //showFilterEditMenu()
            sender.selected = true
        }
    }
    
    func setControlsInEditMenu(buttonTag: Int?){
        // get the selected filter
        if let selectedButtonTag = buttonTag {
            if var filterParameters = appContext.filters[appContext.buttonFilterMap[selectedButtonTag]!]?.Parameters {
            
                let sortedParamNames = filterParameters.keys.sort({$0 < $1})
                for var i = 0; i < sortedParamNames.count; i++ {
                    let param = filterParameters[sortedParamNames[i]]!
                    
                    if let minimumValue = param.MinValue {
                        filterEditMenuSlider.minimumValue = Float(minimumValue)
                    }
                    else{
                        filterEditMenuSlider.minimumValue = -100
                    }
                    
                    if let maximumValue = param.MaxValue {
                        filterEditMenuSlider.maximumValue = Float(maximumValue)
                    }
                    else{
                        filterEditMenuSlider.maximumValue = 100
                    }
                    
                    if let value = param.AppliedValue {
                        filterEditMenuSlider.value = Float(value)

                    }
                    else{
                         filterEditMenuSlider.value = 0
                    }
                    
                    filterNameLabel.text = appContext.filters[appContext.buttonFilterMap[selectedButtonTag]!]?.Name
                    oldSliderValue = filterEditMenuSlider.value
                }
            }
        }
    }
    
    func showFilterEditMenu(buttonTag: Int) {
        if appContext.filters[appContext.buttonFilterMap[buttonTag]!]?.Parameters != nil {
            view.addSubview(filterEditMenu)
            
            let bottomConstraint = filterEditMenu.bottomAnchor.constraintEqualToAnchor(secondaryMenu.topAnchor)
            let leftConstraint = filterEditMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
            let rightConstraint = filterEditMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
            let heightConstraint = filterEditMenu.heightAnchor.constraintEqualToConstant(50)
            
            NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
            
            setControlsInEditMenu(buttonTag)
            view.layoutIfNeeded()
            
            self.filterEditMenu.alpha = 0
            UIView.animateWithDuration(0.4) {
                self.filterEditMenu.alpha = 1.0
            }
        }
        else {
            hideFilterEditMenu()
        }
        
    }
    
    func hideFilterEditMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.editButton.selected = false
            self.filterEditMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.filterEditMenu.removeFromSuperview()
                }
        }
    }
    
    @IBAction func onFilterEditMenuSliderChanged(sender: UISlider) {
        if sender.value == (sender.minimumValue + sender.maximumValue) / 2 {
            sliderMidpointLine.tintColor = UIColor.redColor()
            sliderMidpointLine.backgroundColor = UIColor.redColor()
        }
        else if sender.value > (sender.minimumValue + sender.maximumValue) / 2 {
            sliderMidpointLine.tintColor = self.view.tintColor
            sliderMidpointLine.backgroundColor = self.view.tintColor
        }
        else {
            sliderMidpointLine.tintColor = UIColor.grayColor()
            sliderMidpointLine.backgroundColor = UIColor.grayColor()
        }
        
        let sliderValue = sender.value
        appContext.addFilterToFilterChain(lastSelectedButtonTag!)
        
        if var filterParameters = appContext.filters[appContext.buttonFilterMap[lastSelectedButtonTag!]!]?.Parameters {
            let sortedParamNames = filterParameters.keys.sort({$0 < $1})
            for var i = 0; i < sortedParamNames.count; i++ {
                let param = filterParameters[sortedParamNames[i]]!
                applyFilter(lastSelectedButtonTag!, parameters: [param.Name: Int(sliderValue)])
            }
        }
    }
    
    func toggleFilterButtonSelected(button: UIButton){
        if appContext.filters[appContext.buttonFilterMap[button.tag]!]?.Parameters == nil {
            if !button.selected {
                button.selected = true
                button.tintColor = self.view.tintColor
                showFilterEditMenu(button.tag)
                lastSelectedButtonTag = button.tag
                appContext.addFilterToFilterChain(button.tag)
            }
            else if button.selected {
                button.selected = false
                button.tintColor = UIColor.whiteColor()
                hideFilterEditMenu()
                editButton.enabled = false
                appContext.removeFilterFromFilterChain(button.tag)
            }
        }
        else{
            if !button.selected  {
                lastSelectedFilterButton?.selected = false
                lastSelectedFilterButton?.tintColor = UIColor.whiteColor()
                button.selected = true
                button.tintColor = self.view.tintColor
                showFilterEditMenu(button.tag)
                lastSelectedButtonTag = button.tag
                lastSelectedFilterButton = button
            }
            else if button.selected {
                button.selected = false
                button.tintColor = UIColor.whiteColor()
                hideFilterEditMenu()
                editButton.enabled = false
            }
        }
    }
    
    func enableEditMenuForFilterButton(button: UIButton){
        if appContext.filters[appContext.buttonFilterMap[button.tag]!]?.Parameters != nil {
            editButton.enabled = true
            lastSelectedButtonTag = button.tag
        }
        else{
            editButton.enabled = false
        }
    }
    
    func disableFilterButtons(){
        if filterButton.selected {
            for subView in self.secondaryMenu.subviews[0].subviews{
                if subView.isKindOfClass(UIButton) {
                    let filterButton = subView as! UIButton
                    filterButton.enabled = false
                }
            }
        }
    }
    
    func enableFilterButtons(){
        for subView in self.secondaryMenu.subviews[0].subviews{
            if subView.isKindOfClass(UIButton) {
                let filterButton = subView as! UIButton
                filterButton.enabled = true
            }
        }
    }
    
    func enableFilterEditMenuControls(){
        self.filterEditMenu.userInteractionEnabled = true
    }
    
    func disableFilterEditMenuControls(){
        self.filterEditMenu.userInteractionEnabled = false
    }
    
    // MARK: Apply Filters
    func applyFilter(buttonTag: Int, parameters: [String: Int]?){
        appContext.applyFilterToImage(buttonTag, filterParameters: parameters)
        crossFadeImageViewToImage(appContext.filteredImage)
        compareButton.enabled = true
    }
    
    @IBAction func onBlackAndWhiteFilter(sender: UIButton) {
        toggleFilterButtonSelected(sender)
        applyFilter(sender.tag, parameters: nil)
    }

    @IBAction func onBrightnessFilter(sender: UIButton) {
        toggleFilterButtonSelected(sender)
    }
    
    @IBAction func onContrastFilter(sender: UIButton) {
        toggleFilterButtonSelected(sender)
    }
    
    @IBAction func onChannelFilter(sender: UIButton) {
        toggleFilterButtonSelected(sender)
        applyFilter(sender.tag, parameters: nil)
    }

    @IBAction func onNegativeFilter(sender: UIButton) {
        toggleFilterButtonSelected(sender)
        applyFilter(sender.tag, parameters: nil)
    }
}

