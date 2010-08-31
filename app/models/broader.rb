# skos:broader relates one skos:concept (the owner) to another skos:concept (the target),
# saying that the target is a broader term than the owner.
# a skos:broader relation is NOT transitive, use skos:broaderTransitive instead.
# although technically, skos:broader is the inverse of skos:narrower, for better (?)
# search performance we always create the two relations: A (broader) B and B (narrower) A.
class Broader < SemanticRelation # ActiveRecord::Base

end
