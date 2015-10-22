
import Image, ImageDraw, ImageFont
import random

f = ImageFont.truetype("fonts/BENIGHTE.TTF", 100)

def get_random_fill():
    return (random.random()*200+55,random.random()*200+55,random.random()*200+55)

def get_word_image(word, font=f):
    word_image = Image.new("RGBA", (1200,800))
    ImageDraw.Draw(word_image).text((0,0), word, font=font, fill=get_random_fill())
    return word_image.crop(word_image.getbbox())

def get_word_size(word_image):
    x1, y1, x2, y2 = word_image.getbbox()
    return x2-x1, y2-y1

class Berdle :
    
    def __init__ (self) :
        self.canvas = Image.new("RGB", (2000,2000))
        self.draw = ImageDraw.Draw(self.canvas)
        #self.draw.text((900,900), "lorem", font=f, fill=get_random_fill())
        self.mono = self.canvas.convert("1")

    def is_free(self, pos, size, spacing=4):
        s = spacing
        return self.mono.crop((pos[0]-s,pos[1]-s,pos[0]+size[0]+s, pos[1]+size[1]+s)).getextrema()[1]==0
    
    def plot_word(self, word_image):
        self.canvas.paste(word_image, (self.x, self.y))
        self.mono = self.canvas.convert("1")

    def move_x(self):
        if self.x < 1000 and self.is_free((self.x+2,self.y), self.size):
            self.x = int(self.x+2+.5)
            return True
        elif self.x > 1000 and self.is_free((self.x-2,self.y), self.size):
            self.x = int(self.x-2+.5)
            return True
        return False

    def move_y(self):
        if self.y < 1000 and self.is_free((self.x,self.y+2), self.size):
            self.y = int(self.y+2+.5)
            return True
        elif self.y > 1000 and self.is_free((self.x,self.y-2), self.size):
            self.y = int(self.y-2+.5)
            return True
        return False

    def position_word(self, word, x, y, font_size) :

        self.x = x
        self.y = y

        word_image = get_word_image(word, font=ImageFont.truetype("fonts/BENIGHTE.TTF", int(font_size)))
        if random.random()>.6 :
            word_image = word_image.transpose(Image.ROTATE_90)

        self.size = get_word_size(word_image)
        for i in range(3000) :

            dirty = 0
            if random.random()>0.1 :
                dirty = self.move_y() or self.move_y() or self.move_y() or self.move_x()
            else :
                dirty = self.move_x() or self.move_y()

            if not dirty and self.is_free((self.x,self.y),  self.size) :
                self.plot_word(word_image)
                break

        else :
            if self.is_free((self.x, self.y), self.size) :
                self.plot_word(word_image)
            else :
                print "$$", word 

LOREM = """ipsum dolor sit amet consectetur adipisicing elit sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat
nulla turpis eros tristique vel tempor sit amet, sodales eu, justo proin a
neque a est euismod feugiat quisque lorem mauris pretium non rutrum eget
pretium ut dui curabitur vitae erat sit amet eros condimentum tempus
vestibulum malesuada, odio quis vestibulum sagittis sem pede mattis
tortor ac vehicula mauris sem vel metus Maecenas ut justo curabitur vestibulum
urna sed dapibus molestie nulla nunc gravida velit eu sagittis magna sapien in
ligula class aptent taciti sociosqu ad litora torquent per conubia nostra
per inceptos himenaeos vestibulum sagittis metus in diam"""

berdle = Berdle()

font_size = 100

for line in open("data.txt") :
    word, count = line.strip().split()
    count = int(count)
    print word
    font_size = count / 4
    if random.random() > .5 :
       berdle.position_word(word, random.random()*2000, 100, font_size)
    else:
       berdle.position_word(word, random.random()*2000, 1800, font_size)

berdle.canvas.save("berdle.png")

