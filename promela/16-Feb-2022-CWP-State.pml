/*****************************************************************************/
/* This file defines the variables that comprise the "state" of the CWP with */
/* setters and predicates. The setters give the possible values for each     */
/* state variable. The predicates reflect the edge conditions seen in the    */
/* associated state diagram for the CWP.                                     */
/*                                                                           */
/* Actionionable Risk Awareness Variables: (sevNeed, trndSevNeed, orders)    */
/*                                                                           */
/*   sevNeed: must be assessed and assigned in an exam by a clinician        */
/*   trndSevNeed: assigned by AI and synchronized with sevNeed in exam       */
/*   orders: must be assigned by clinician in an exam                        */
/*                                                                           */
/* This file then defines the conditions required to reside in a given       */
/* state of the associated state diagram for the CWP. Each state is defined  */
/* by the conditions of its incoming and outgoing edges (explained later).   */
/* There is a global boolean variable for each state in the state diagram.   */
/* That variable is set whenever its associated state is active.             */
/*                                                                           */
/* This file ends with weak behavioral models for each of the state          */
/* variables. These are intended to put the least constraints necessary      */
/* on the variables to pass verification by an implementing workflow.        */
/*****************************************************************************/

/*****************************************************************************/
/*                         Patient Severity Need                             */
/*****************************************************************************/
#define INIT 255
#define EXPIRED 254
#define DISCHARGE 0
#define homeCare 2

byte sevNeed = INIT

#define isInit(sevNeed) (sevNeed == INIT)

#define isExpired(sevNeed) (sevNeed == EXPIRED)
#define setExpired(sevNeed) sevNeed = EXPIRED

#define isDischargeLevel(sevNeed) (sevNeed == DISCHARGE)
#define setDischargeLevel(sevNeed) sevNeed = DISCHARGE

#define isWithinHomeCare(sevNeed) (    (sevNeed <= homeCare)        \
                                     && !isInit(sevNeed)            \
                                     && !isExpired(sevNeed)         \
                                     && !isDischargeLevel(sevNeed))
#define setWithinHomeCare(sevNeed) sevNeed = homeCare

#define isOutsideHomeCare(sevNeed) (    (sevNeed > homeCare)        \
                                     && !isInit(sevNeed)            \
                                     && !isExpired(sevNeed)         \
                                     && !isDischargeLevel(sevNeed))
#define setOutsideHomeCare(sevNeed) sevNeed = homeCare + 1

#define isRequiresHospital(sevNeed) (isOutsideHomeCare(sevNeed))

inline logSeverity(sevNeed) {
  if
  :: isWithinHomeCare(sevNeed) ->
    printf("* sevNeed = withinHomeCareCapabilities\n")
  :: (isOutsideHomeCare(sevNeed)) ->
    printf("* sevNeed = outsideHomeCareCapabilities\n")
  :: isInit(sevNeed) ->
    printf("* sevNeed = INIT\n")
  :: isExpired(sevNeed) ->
    printf("* sevNeed = EXPIRED\n")
  :: isDischargeLevel(sevNeed) ->
    printf("* sevNeed = DISCHARGE\n")
  :: else -> 
    printf("ERROR: unknown sevNeed %d\n", sevNeed)
    assert(false)
  fi
}

/*****************************************************************************/
/*                      Patient Severity Need Trend                          */
/*****************************************************************************/
byte trndSevNeed = INIT

inline logTrend(trndSevNeed) {
  if
  :: isWithinHomeCare(trndSevNeed) ->
    printf("* trndsevNeed = withinHomeCareCapabilities\n")
  :: (isOutsideHomeCare(trndSevNeed)) ->
    printf("* trndSevNeed = outsideHomeCareCapabilities\n")
  :: isInit(trndSevNeed) ->
    printf("* trndSevNeed = INIT\n")
  :: isExpired(trndSevNeed) ->
    printf("* trndSevNeed = EXPIRED\n")
  :: isDischargeLevel(trndSevNeed) ->
    printf("* trndSevNeed = DISCHARGE\n")
  :: else -> 
    printf("ERROR: unknown trndSevNeed %d\n", trndSevNeed)
    assert(false)
  fi
}

/*****************************************************************************/
/*                            Doctors Orders                                 */
/*****************************************************************************/
mtype = {home, homePlus, admission, discharge, none}
mtype orders = none

#define isNone(orders) (orders == none)
#define isHomeCare(orders) (orders == home)
#define isHomeCarePlus(orders) (orders == homePlus)
#define isHospital(orders) (orders == admission)
#define isDischarge(orders) (orders == discharge)

#define setHomeCare(orders) orders = home
#define setHomeCarePlus(orders) orders = homePlus
#define setHospital(orders) orders = admission
#define setDischarge(orders) orders = discharge
 
inline logOrders(orders) {
  printf("* orders = %e\n", orders)
}

#define meetsDischargeCriteria(sevNeed, orders) (isDischargeLevel(sevNeed) && isDischarge(orders))
#define setDischargeCriteria(sevNeed, orders) setDischargeLevel(sevNeed) ; setDischarge(orders)

/*****************************************************************************/
/*                            26-Oct-2021-CWP.png                             */
/* States defined by:                                                        */ 
/*    1) Conjunction of all incoming edged                                   */
/*    2) Conjuncted with not the disjunction of incomming edges              */
/*    3) Simplified to remove reduntant (exclusive) terms based on model     */
/* The strongest predicate that includes _every_ incoming condition and      */
/* excludes any outgoing condition.                                          */
/*****************************************************************************/

byte InitState = 1
byte HospitalState = 0
byte ptInAppropriateHomeCareState = 0
byte ptInElevatedRiskHomeCareState = 0 
byte ptDischargedState = 0
byte ptExpiredState = 0

#define edgeA (isWithinHomeCare(sevNeed) && isWithinHomeCare(trndSevNeed))
#define edgeB isOutsideHomeCare(sevNeed)
#define edgeC meetsDischargeCriteria(sevNeed, orders)
#define edgeD (isWithinHomeCare(sevNeed) && isOutsideHomeCare(trndSevNeed))
#define edgeE isOutsideHomeCare(sevNeed)
#define edgeF (isWithinHomeCare(sevNeed) && isWithinHomeCare(trndSevNeed))
#define edgeG isExpired(sevNeed)
#define edgeH isNone(orders)

inline updateState() {
  atomic {
    InitState = 
      (    (edgeH)
        && (! (edgeA || edgeB))
      )
    HospitalState = 
      (    (edgeB && edgeE)
        && (! (edgeC || edgeG))
      )
    ptInAppropriateHomeCareState = 
      (    (edgeA && edgeF)
        && (! (edgeC || edgeD))
      )
    ptInElevatedRiskHomeCareState =
      (    (edgeD)
        && (! (edgeE || edgeF || edgeG))
      )
    ptDischargedState = edgeC
    ptExpiredState = edgeG
    logState()
  }
}

inline logState() {
  printf("*********************************************\n")
  if
  :: (InitState) -> 
    printf("* InitState\n")
  :: else
  fi
  
  if
  :: (HospitalState) -> 
    printf("* HospitalState\n")
  :: else
  fi

  if
  :: (ptInAppropriateHomeCareState) -> 
    printf("* ptInAppropriateHomeCareState\n")
  :: else
  fi

  if
  :: (ptInElevatedRiskHomeCareState) -> 
    printf("* ptInElevatedRiskHomeCareState\n")
  :: else
  fi

  if
  :: (ptDischargedState) -> 
    printf("* ptDischarged\n")
  :: else
  fi

  if
  :: (ptExpiredState) -> 
    printf("* ptExpired\n")
  :: else
  fi
  logEdges()
  logSeverity(sevNeed)
  logTrend(trndSevNeed)
  logOrders(orders)
  printf("*********************************************\n")
}

inline logEdges() {
  printf("* edgeA = %d\n", edgeA)
  printf("* edgeB = %d\n", edgeB)
  printf("* edgeC = %d\n", edgeC)
  printf("* edgeD = %d\n", edgeD)
  printf("* edgeE = %d\n", edgeE)
  printf("* edgeF = %d\n", edgeF)
  printf("* edgeG = %d\n", edgeG)
  printf("* edgeH = %d\n", edgeH)
}