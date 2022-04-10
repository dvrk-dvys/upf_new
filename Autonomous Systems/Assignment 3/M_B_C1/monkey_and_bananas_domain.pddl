(define (domain monkey-bananas)	       
  (:requirements :strips)
 
  (:constants monkey chair bananas)
 
  (:predicates (location ?x)
	       (on-floor)
	       (at ?m ?x)
	       (onchair ?x)
	       (hasbananas))
  
  (:action MOVE-MONKEY
	     :parameters (?x ?y)
	     :precondition (and (location ?x) (location ?y) (on-floor) (at monkey ?y))
	     :effect (and (at monkey ?x) (not (at monkey ?y))))

  (:action CLIMB
	     :parameters (?x)
	     :precondition (and (location ?x) (at chair ?x) (at monkey ?x))
	     :effect (and (onchair ?x) (not (on-floor))))

  (:action MOVE-CHAIR
	     :parameters (?x ?y)
	     :precondition (and (location ?x) (location ?y) (at chair ?y) (at monkey ?y)
				 (on-floor))
	     :effect (and (at monkey ?x) (not (at monkey ?y))
			   (at chair ?x)    (not (at chair ?y))))

  (:action GET-BANANAS
	     :parameters (?y)
	     :precondition (and (location ?y)
                (at bananas ?y) (onchair ?y))
	     :effect (hasbananas))
)