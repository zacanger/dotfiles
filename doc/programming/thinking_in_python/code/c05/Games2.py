#: c05:Games2.py
# Simplified Abstract Factory.

class Kitty:
  def interactWith(self, obstacle):
    print "Kitty has encountered a",
    obstacle.action()

class KungFuGuy:
  def interactWith(self, obstacle):
    print "KungFuGuy now battles a",
    obstacle.action()

class Puzzle:
  def action(self): print "Puzzle" 

class NastyWeapon:
  def action(self): print "NastyWeapon" 

# Concrete factories:
class KittiesAndPuzzles:
  def makePlayer(self): return Kitty()
  def makeObstacle(self): return Puzzle()

class KillAndDismember:
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
