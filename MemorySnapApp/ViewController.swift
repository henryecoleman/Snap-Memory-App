//
//  ViewController.swift
//  MemorySnapApp
//
//  Created by H Coleman on 28/12/2020.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource , UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    let model = CardModel()
    var cardsArray = [Card]()
    
    var timer:Timer?
    var milliseconds:Int = 10 * 1000
    
    var firstFlippedCardIndex:IndexPath?
    
    var soundPlayer = SoundManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       cardsArray = model.getCards()
        
        // Set the view controller as the datasource and delegate of the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Initialise the timer
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Play Shuffle File
        soundPlayer.playSound(effect: .shuffle)
    }
    
    
    // MARK: - Timer Methods
    
    @objc func timerFired() {
        
        //Decrement the counter
        milliseconds -= 1
        
        // Update the label
        let secounds:Double = Double(milliseconds)/1000.0
        timerLabel.text = String(format: "Time remaining: %.2f", secounds)
        
        //Stop the timer
        if milliseconds == 0 {
            
            timerLabel.textColor = UIColor.red
            timer?.invalidate()
            
            //TODO Check if the timer has reached zero
            checkForGameEnd()
            
        }
        
    }
    
    // MARK: - Collection View Deletage Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // return number of cards
        return cardsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        // Return it
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // configure the state of the cell based on the properties of the card that it represents
        
        let cardcell = cell as? CardCollectionViewCell
        
        // Get the card from the card array
        let card = cardsArray[indexPath.row]
        
        // Finish Configuring the cell
        cardcell?.configureCell(card: card)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if milliseconds <= 0 {
            return
        }
        
        // Get a reference to the cell that was tapped
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        
        
        // Check the status of the card to determine how to flip it
        if cell?.card?.isFlipped == false && cell?.card?.isMatched == false {
            
            // flip the card up
            cell?.flipUp()
            
            // Play Sound
            soundPlayer.playSound(effect: .flip)
          
        // Check if this was the first card that was flipped or the second card
        
        if firstFlippedCardIndex == nil {
            
            // This is the first card flipped over
            firstFlippedCardIndex = indexPath
        }
        else {
            // Second card that is flipped
            
            // Run the comparison logic
            checkForMatch(indexPath)
        }
        }
        
    }
    
    // MARK: - Game logic Methods
    
    func checkForMatch(_ secondFlippedCardIndex:IndexPath) {
        
        // Get the two card objects for the two indicies and see if they match
        
        let cardOne = cardsArray[firstFlippedCardIndex!.row]
        let cardTwo = cardsArray[secondFlippedCardIndex.row]
        
        // Get the two collection view cells that represent card one and two
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        // Compare the two cards
        if cardOne.imageName == cardTwo.imageName {
            
            // It's a match
            
            // Play Match Sound
            soundPlayer.playSound(effect: .match)
            
            // Set the staus and then remove
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // Was that the last pair
            checkForGameEnd()
           
        }
        else {
            
            // It's not a match
            
            // Play not a match sound
            soundPlayer.playSound(effect: .nomatch)
            
            // Flip them back over
            cardOneCell?.flipDown()
            cardTwoCell?.flipDown()
            
        }
        
        // Rest the firstFlippedCardIndexproperty
        firstFlippedCardIndex = nil
    }
    
    func checkForGameEnd() {
        
        // Check for any unmatched cards
        // Assume user has won and loop through all the cards to see if there matched
        var hasWon = true
        
        for card in cardsArray {
            if card.isMatched == false {
                // Weve found a card thats matched
                hasWon = false
                break
            }
        }
        
        if hasWon == true {
            // User has won show alert
            showAlert(title: "Congratulations", message: "Youve Won the Game")
        }
        else {
            // User hasnt won yet , check for time left
            if milliseconds <= 0 {
                showAlert(title: "Times UP", message: "Try Again, My Friend")
            }
        }
    }
    func showAlert(title: String, message: String) {
        
        // Create the alert
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add button for user to dismiss
        let okAction  = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        // Show alert
        present(alert, animated: true, completion: nil)
    }

}

