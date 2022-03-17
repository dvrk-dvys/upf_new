(define (domain M-B-Prob)
    (:extends life-expectancy)
    (:requirements :strips :typing)

    (:constants monkey bananas chair)

    (:predicates (location ?x)
                 (on-floor)
                 (at ?m ?x)
                 (on-chair ?x)
                 (has-banana ?y ?x)
                 (has-all-bananas ?x)
    )
    (:action MOVE-MONKEY-TO
        :parameters (?x ?y)
        :precondition (and
            (location ?x)
            (location ?y)
            (not (= ?x ?y))
            (on-floor)
            (at monkey ?x)
        )
        :effect (and
            (at monkey ?x)
            (not (at monkey ?y))
        )
	)
    (:action CLIMB
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
            (not (= ?x ?y))
            (at chair ?y)
            (at monkey ?y)
            (on-floor))
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
            (on-chair ?y))
        )
        :effect (has-banana ?y)
        )
    )
    (:axiom
        :vars (?x - location)
        :context (and
            (has-banana ?x)
        )
        :implies (has-all-bananas ?x)
    )
)