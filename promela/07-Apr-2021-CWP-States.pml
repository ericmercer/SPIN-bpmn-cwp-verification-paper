/*****************************************************************************/
/*                            7-Apr-2021-CWP.png                             */
/* States defined by:                                                        */ 
/*    1) Conjunction of all incoming edged                                   */
/*    2) Conjuncted with not the disjunction of incomming edges              */
/*    3) Simplified to remove reduntant (exclusive) terms based on model     */
/* The strongest predicate that includes _every_ incoming condition and      */
/* excludes any outgoing condition.                                          */
/*****************************************************************************/

/*****************************************************************************/
/*                               CWP States                                  */
/*****************************************************************************/
#define HospitalState                                                         \
(                                                                             \
     (    isRequiresHospital(sevLvl)                                        \
       && isHospital(orders)                                                  \
     )                                                                        \
)

#define ptInAppropriateHomeCareState                                          \
(                                                                             \
     (    (! isRequiresHospital(sevLvl))                                    \
       && isHomeCare(orders)                                                  \
       && isWithinCareCapability(sevLvl)                                    \
       && isWithinCareCapability(trndSevLvl)                               \
     )                                                                        \
)

#define ptInElevatedRiskHomeCareState                                         \
(                                                                             \
     (    (! isRequiresHospital(sevLvl))                                    \
       && isHomeCare(orders)                                                  \
       && isWithinCareCapability(sevLvl)                                    \
       && (! isWithinCareCapability(trndSevLvl))                           \
     )                                                                        \
)   

#define ptDischargedState                                                     \
(                                                                             \
  isDischarge(orders)                                                         \
)

#define ptExpiredState                                                        \
(                                                                             \
  isFatality(sevLvl)                                                        \
)                                                                             \

/*****************************************************************************/
/*                           No uncovered states                             */
/*****************************************************************************/

#define inAState          HospitalState                                       \
                       || ptInAppropriateHomeCareState                        \
                       || ptInElevatedRiskHomeCareState                       \
                       || ptDischargedState                                   \
                       || ptExpiredState                                      
ltl alwayInAState {(always (inAState))}

/*****************************************************************************/
/*                           Fairness Property                               */
/*****************************************************************************/
#define fair                                                                  \
  (                                                                           \
    (                                                                         \
      (eventually (ptDischargedState || ptExpiredState))                      \
    )                                                                         \
  )
ltl fairPathExists {(always (! fair))}

/*****************************************************************************/
/*                Patient Discharged State Verification                      */
/*****************************************************************************/
ltl ptDischargedExists {(fair implies (always (! ptDischargedState)))}
ltl ptDischargedMutex {
  ( 
    always (
      ptDischargedState implies (
        (
             (! HospitalState)
          && (! ptInAppropriateHomeCareState)
          && (! ptInElevatedRiskHomeCareState)
          && ptDischargedState
          && (! ptExpiredState)
        )
      )
    )
  )
}
ltl ptDischargedEdges {
  (
    fair implies (
      always (
        ptDischargedState implies (
          (always ptDischargedState)
        )
      )
    )
  )
}

/*****************************************************************************/
/*                   Patient Expired State Verification                      */
/*****************************************************************************/
ltl ptExpiredExists {(fair implies (always (! ptExpiredState)))}
ltl ptExpiredMutex {
  ( 
    always (
      ptExpiredState implies (
        (
             (! HospitalState)
          && (! ptInAppropriateHomeCareState)
          && (! ptInElevatedRiskHomeCareState)
          && (! ptDischargedState)
          && ptExpiredState
        )
      )
    )
  )
}
ltl ptExpiredEdges {
  (
    fair implies (
      always (
        ptExpiredState implies (
          (always ptExpiredState)
        )
      )
    )
  )
}

/*****************************************************************************/
/*                        ICU State Verification                            */
/*****************************************************************************/
ltl ICUExists {(fair implies (always (! HospitalState)))}
ltl ICUMutex {
  ( 
    always (
      HospitalState implies (
        (
             HospitalState
          && (! ptInAppropriateHomeCareState)
          && (! ptInElevatedRiskHomeCareState)
          && (! ptDischargedState)
          && (! ptExpiredState)
        )
      )
    )
  )
}
ltl ICUEdges {
  (
    fair implies (
      always (
        HospitalState implies (
          HospitalState until (
                ptInAppropriateHomeCareState
            ||  ptExpiredState
            ||  ptDischargedState
          )
        )
      )
    )
  )
}

/*****************************************************************************/
/*              ptInAppropriateHomeCare State Verification                   */
/*****************************************************************************/
ltl ptInAppropriateHomeCareExists {(fair implies (always (! ptInAppropriateHomeCareState)))}
ltl ptInAppropriateHomeCareMutex {
  ( 
    always (
      ptInAppropriateHomeCareState implies (
        (
             (! HospitalState)
          && ptInAppropriateHomeCareState
          && (! ptInElevatedRiskHomeCareState)
          && (! ptDischargedState)
          && (! ptExpiredState)
        )
      )
    )
  )
}
ltl ptInAppropriateHomeCareEdges {
  (
    fair implies (
      always (
        ptInAppropriateHomeCareState implies (
          ptInAppropriateHomeCareState until (
                ptInElevatedRiskHomeCareState
            ||  ptDischargedState
          )
        )
      )
    )
  )
}

/*****************************************************************************/
/*              ptInElevatedRiskHomeCare State Verification                  */
/*****************************************************************************/
ltl ptInElevatedRiskHomeCareExists {(fair implies (always (! ptInElevatedRiskHomeCareState)))}
ltl ptInElevatedRiskHomeCareMutex {
  ( 
    always (
      ptInElevatedRiskHomeCareState implies (
        (
             (! HospitalState)
          && (! ptInAppropriateHomeCareState)
          && ptInElevatedRiskHomeCareState
          && (! ptDischargedState)
          && (! ptExpiredState)
        )
      )
    )
  )
}
ltl ptInElevatedRiskHomeCareEdges {
  (
    fair implies (
      always (
        ptInElevatedRiskHomeCareState implies (
          ptInElevatedRiskHomeCareState until (
                ptExpiredState
            ||  HospitalState
            ||  ptInAppropriateHomeCareState
          )
        )
      )
    )
  )
}