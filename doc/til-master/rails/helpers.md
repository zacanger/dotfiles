#Helpers

##"Helpers are shit"
http://nicksda.apotomo.de/2011/10/rails-misapprehensions-helpers-are-shit/

tl;dr

Helpers are good for when you want to include your method everyfrickingwhere,
since rails loads ALL HELPERS in ALL VIEWS.  Nick Sutterer asks, "...what
happens if I have two #capitalize methods in two different helpers mixed in the
same view?".  Good question...  We don't really know that.
