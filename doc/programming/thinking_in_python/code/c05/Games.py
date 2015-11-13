#: c05:Games.py
# An example of the Abstract Factory pattern.

class Obstacle:
  def action(self): pass

class Player:
  def interactWith(self, obstacle): pass

class Kitty(Player):
  def interactWith(self, obstacle):
    print "Kitty has encountered a",
    obstacle.action()

class KungFuGuy(Player):
  def interactWith(self, obstacle):
    print "KungFuGuy now battles a",
    obstacle.action()

class Puzzle(Obstacle):
  def action(self): 
    print "Puzzle" 

class NastyWeapon(Obstacle):
  def action(self): 
    print "NastyWeapon" 

# The Abstract Factory:
class GameElementFactory:
  def makePlayer(self): pass
  def makeObstacle(self): pass

# Concrete factories:
class KittiesAndPuzzles(GameElementFactory):
  def makePlayer(self): return Kitty()
  def makeObstacle(self): return Puzzle()

class KillAndDismember(GameElementFactory):
  def makePlayer(self): return KungFuGuy()
  def makeObstacle(self): return NastyWeapon()

class GameEnvironment:
  def __init__(self, factory):
    self.factory = factory
    self.p = factory.makePlayer() 
    self.ob = factory.makeObstacle()
  def play(self): 
    self.p.interactWith(self.ob) 

g1 = GameEnvironment(KittiesAndPuzzles())
g2 = GameEnvironment(KillAndDismember())
g1.play() 
g2.play() 
#<hr>
output = '''
Kitty has encountered a Puzzle
KungFuGuy now battles a NastyWeapon
'''
