/*****************************************************************************/
/*                            Doctors Orders                                 */
/*****************************************************************************/
mtype = {home, admission, discharge, none}
mtype orders = none

#define isNone(orders) (orders == none)

#define isHomeCare(orders) (orders == home)

#define setHomeCare(orders) orders = home

#define isHospital(orders) (orders == admission)

#define setHospital(orders) orders = admission

#define isDischarge(orders) (orders == discharge)

#define setDischarge(orders) orders = discharge
 
inline logOrders(orders) {
  printf("orders = %e\n", orders)
}

//****************************************************************************/
/*                         Patient Severity Need                             */
/*****************************************************************************/

#define EXPIRED 255
#define INIT 42
#define homeCare 2

byte sevNeed = INIT

#define isINIT(sevNeed) (sevNeed == INIT)
#define isFatality(sevNeed) (sevNeed == EXPIRED)

#define isWithinHomeCare(sevNeed) (sevNeed <= homeCare)
#define setWithinHomeCare(sevNeed) sevNeed = homeCare
#define setOutsideHomeCare(sevNeed) sevNeed = homeCare + 1
#define setSeverity(sevNeed, value) sevNeed = value

#define isRequiresHospital(sevNeed) ((! isINIT(sevNeed)) && (! isWithinHomeCare(sevNeed)) && (! isFatality(sevNeed)))

inline logSeverity(sevNeed) {
  printf("sevNeed = %d\n", sevNeed)
}

/*****************************************************************************/
/*                      Patient Severity Need Trend                          */
/*****************************************************************************/
byte trndSevNeed = INIT

inline logTrend(trndSevNeed) {
  printf("trendSeverity = %d\n", trndSevNeed)
}

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

inline updateState() {
  atomic {
    InitState = isNone(orders)
    HospitalState = 
      (    isRequiresHospital(sevNeed)
        && isHospital(orders)
      )
    ptInAppropriateHomeCareState = 
      (    (! isRequiresHospital(sevNeed))
        && isHomeCare(orders)
        && isWithinHomeCare(sevNeed)
        && isWithinHomeCare(trndSevNeed)
      )
    ptInElevatedRiskHomeCareState =
      (    (! isRequiresHospital(sevNeed))
        && isHomeCare(orders)
        && isWithinHomeCare(sevNeed)
        && (! isWithinHomeCare(trndSevNeed))
      )
    ptDischargedState = isDischarge(orders)
    ptExpiredState = isFatality(sevNeed)
  }
}

/*****************************************************************************/
/*                    Behavior Model for Patient Severity                    */
/*****************************************************************************/
inline updatePatientSeverity(trndSevNeed, sevNeed) {
  if
  :: true -> setWithinHomeCare(sevNeed)
  :: trndSevNeed > homeCare -> setOutsideHomeCare(sevNeed)
  fi 
  updateState()
  logSeverity(sevNeed)
}

inline updatePatientMortality(trndSevNeed, sevNeed) {
  if
  :: (! isWithinHomeCare(trndSevNeed)) -> 
    setSeverity(sevNeed, EXPIRED)
  :: (! isWithinHomeCare(sevNeed)) ->
    setSeverity(sevNeed, EXPIRED)
  :: true
  fi
  updateState()
  logSeverity(sevNeed)
}

/*****************************************************************************/
/*                     Behavior Model for Severity Trend                     */
/*****************************************************************************/
inline updateSeverityTrend(trndSevNeed) {
  if
  :: true -> setWithinHomeCare(trndSevNeed)
  :: true -> setOutsideHomeCare(trndSevNeed)
  fi
  updateState()
  logTrend(trndSevNeed)
}

/*****************************************************************************/
/*                     Behavior Model for Doctor Orders                      */
/*****************************************************************************/
inline updateDoctorOrders(sevNeed, orders) {
  if
  :: (sevNeed > homeCare) ->
    setHospital(orders)
  :: else -> 
    if
      :: (isNone(orders) || isWithinHomeCare(sevNeed)) ->
        setHomeCare(orders)
      :: (!isNone(orders) && isWithinHomeCare(trndSevNeed)) ->
        setDischarge(orders)
    fi
  fi
  updateState()
  logOrders(orders)
}
