# Ich habe den Ausmass der Misere bei den Ruby-Strings
# unterschätzt. Es muss bei den übelsten Hacks bleiben.
# Weniger üble Hacks sind wohl auf Rails-Basis möglich
# http://api.rubyonrails.org/classes/ActiveSupport/Multibyte/Handlers/UTF8Handler.html
# Aber richtig toll erscheint es mir auch nicht.
# Für Ruby 1.9 ist keine Verbesserung vorgesehen
# sondern es soll noch schlimmer werden,
# dabei denken die Schuldigen, es wäre eine Verbesserung.
# Die Armleuchten reden immer noch von String-Encoding:
# http://www.intertwingly.net/blog/2007/12/29/Ruby-1-9-Strings-Updated
# Dabei sollten die Strings *kein* Encoding haben, 
# sondern nur einen Array von Codepoints (sowas wie Buchstaben) enthalten.
# Byte-Streams, wie Dateien, Netzwerk-Streams und andere sollten dagegen
# unter der Angabe des Encodings (in HTTP ist die Angabe integriert),
# bei Dateien muss man entweder wissen (vereinbaren) oder BOM verwenden.
# Dieses einfache, elegante, klare Konzept wird erfolgreich bei
# * Java
# * .NET Framework
# * Python verwendet
# seit Jahren verwendet.
 
# Sinnloses überflüssiges Escaping der Unicode Character eliminieren
# Weitere Verbesserung wäre 
# * nicht hier, sondern bei String.to_xs eingreifen und somit
#   auch die Performance verbessern
# * diese Abkürzung abhängig von der bei der XML builder 
#   angegebenem Encoding abhängig machen. Dafür müsste man
#   entweder builder API erweitern oder xmlmarkup#instruct! auswerten

#class Fixnum
#  XChar = Builder::XChar if ! defined?(XChar)
#
#  # XML escaped version of chr
#  def xchr
#    n = XChar::CP1252[self] || self
#    case n when *XChar::VALID
#      XChar::PREDEFINED[n] or self.chr # (n<128 ? n.chr : "&##{n};")
#    else
#      '*'
#    end
#  end
#end
