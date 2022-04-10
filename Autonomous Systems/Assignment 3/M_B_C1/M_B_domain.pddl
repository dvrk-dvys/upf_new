(define (domain M-B-Prob)
    (:requirements :strips)

    (:constants monkey chair bananas)

    (:predicates (location ?x)
               (on-floor)
               (at ?m ?x)
               (on-chair ?x)
               (has-all-bananas)
    )

    (:action MOVE-MONKEY-TO
        :parameters (?x ?y)
        :precondition (and
            (location ?x)
            (location ?y)
            (on-floor)
            (at monkey ?y)
        )
        :effect (and
            (at monkey ?x)
            (not (at monkey ?y))
        )
    )

    (:action CLIMB-UP
        :parameters (?x)
        :precondition (and
            (location ?x)
            (at chair ?x)
            (at monkey ?x)
        )
        :effect (and
            (on-chair ?x)
            (not (on-floor))
        )
    )

    (:action MOVE-CHAIR
        :parameters (?x ?y)
        :precondition (and
            (location ?x)
            (location ?y)
            (at chair ?y)
            (at monkey ?y)
            (on-floor)
        )
        :effect (and
            (at monkey ?x)
            (not (at monkey ?y))
            (at chair ?x)
            (not (at chair ?y))
        )
    )

    (:action REACH-BANANA
        :parameters (?y)
        :precondition (and
            (location ?y)
            (at bananas ?y)
            (on-chair ?y)
        )
        :effect (has-all-bananas)
    )
)