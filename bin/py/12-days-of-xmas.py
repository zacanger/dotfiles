#/usr/bin/env python

def getGift(day):
    return (
        1:  "a partridge in a pear tree.",
        2:  "two turtle doves,",
        3:  "three french hens,",
        4:  "four calling birds,",
        5:  "five golden rings,",
        6:  "six geese a-laying,",
        7:  "seven swans a-swimming,",
        8:  "eight maids a-milking,",
        9:  "nine ladies dancing,",
        10: "ten lords a-leaping,",
        11: "eleven pipers piping,",
        12: "twelve drummers drumming,",
        ).get(day, "")

def getOrdinal(num):
    return (
        1: "st",
        2: "nd",
        3: "rd",
        ).get(num, "th")

for verse in range(1, 13):
    print("On the " + str(verse)+ getOrdinal(verse) + " day of xmas, my true love gave to me:")
    for gift in range(verse, 0, -1):
        if(verse > 1 and gift == 1):
            print("And " + getGift(gift))
        else:
            print(getGift(gift))
    print()
input()

