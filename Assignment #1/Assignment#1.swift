//
//  Assignment#1.swift
//  
//
//  Created by Student on 12.09.2026.
//
import Foundation

//import UIKit


// Step 1: Declaring vars for personal info
var firstName: String = "Louay"
var lastName:String = "Ziani"
var age: Int = 20
var birthYear: Int = 2006
var isStudent: Bool = true
var height: Double = 1.88
//additional details
var nationality: String = "Moroccan"
var studyYear: Int = 4

let currentYear = 2026
age = currentYear - birthYear

//Step 2: Vars for hobbies and interests
var hobby: String = "Football"
var numberOfHobbies: Int = 5
var favoriteNumber: Int = 3
var isHobbyCreative: Bool = true
//additional details
var otherHobby: String = "Basketball"
var numberOfFriends: Int = 10
var favoriteHooper: String = "Jalen Brunson"


//Step 3: Summary of my life story
var lifeStory: String = """
      My name is \(firstName) \(lastName). I am a \(age) years old \(nationality), born in \(birthYear). I am currently a student. I enjoy playing \(hobby), which is a creative hobby. I also enjoy playing \(otherHobby) in my free time. I have \(numberOfHobbies) hobbies in total, that I usually play with my \(numberOfFriends) friends. My favorite basketball player is \(favoriteHooper), whilst my favorite number is \(favoriteNumber). 
      """

//Step 4: Printing life story
print(lifeStory)

//Bonus task
var futureGoals: String = "I want to be a successful \(otherHobby) player and maybe open a \(otherHobby) academy."

lifeStory = lifeStory + futureGoals
print(lifeStory)

