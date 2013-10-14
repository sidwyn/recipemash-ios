Recee
================================
Your pocket receipt to recipe converter.

Hacked up at Facebook NorCal Regional Hackathon 2013 (third place!)

iOS app and design done by Sidwyn Koh.

![Sample screenshot](http://i.imgur.com/NKoYxaF.png?1)

This was hacked up in 20 hours and some minor cleanups were performed, so bugs are definitely present!

How It Works
-------------------------
1. Take image (comment out Line 234-240 in ViewController.m to use your own image)
2. Converts it to grayscale and decreases the size
3. Use Tesseract to translate from image to text and remove unnecessary symbols
4. Remove unnecessary symbols and whitespace
5. Picks out what ingredients are most likely against a sample Grocery List (see GroceryList.plist), using the Levensthein Distance algorithm (picked this up in CS61A last week!)
6. Uploads it to virtual fridge via Facebook
7. Polls the Yummly API to get a list of recipes

Libraries
-------------------------
1. [Tesseract-iOS](https://github.com/ldiqual/tesseract-ios) by Daniele Galiotto
2. [Tesseract Lib for iOS](https://github.com/ldiqual/tesseract-ios-lib) by ldiqual
3. [NSString+Levenshtein](https://github.com/jigish/slate/blob/master/Slate/NSString%2BLevenshtein.m) by Jigish Patel
4. [VTPG_Common](https://github.com/VTPG/CommonCode/blob/master/VTPG_Common.m) by Vincent Gable
5. [Grayscale/Resizing for Tesseract](http://stackoverflow.com/a/13545697/338926) by roocell

APIs
-------------------------
1. [Food2Fork](http://food2fork.com/about/api)
2. [Yummly](https://developer.yummly.com/)
3. [Facebook Login](https://developers.facebook.com/docs/facebook-login/)