/*****************************************************************************/
/*                            Doctors Orders                                 */
/*****************************************************************************/
mtype = {homeCare, admission, discharge, none}
mtype orders = none

#define isNone(orders) (orders == none)

#define isHomeCare(orders) (orders == homeCare)

#define setHomeCare(orders) orders = homeCare

#define isHospital(orders) (orders == admission)

#define setHospital(orders) orders = admission

#define isDischarge(orders) (orders == discharge)

#define setDischarge(orders) orders = discharge
 
inline logOrders(orders) {
  printf("orders = %e\n", orders)
}

//****************************************************************************/
/*                            Patient Severity                               */
/*****************************************************************************/
#define EXPIRED 255
#define INIT 42

byte sevLvl = INIT

#define setSeverity(sevLvl, value) sevLvl = value
#define isINIT(sevLvl) (sevLvl == INIT)
#define isRequiresHospital(sevLvl) (sevLvl >= 2 && sevLvl != EXPIRED)
#define isFatality(sevLvl) (sevLvl == EXPIRED)

inline logSeverity(sevLvl) {
  printf("sevLvl = %d\n", sevLvl)
}

//****************************************************************************/
/*                      Patient Care Capability Level                        */
/*****************************************************************************/
byte careCapLvl = 2

#define setCareCapability(careCabapility, value) careCabapility = value
#define isWithinCareCapability(sevLvl) (sevLvl < careCapLvl)
#define setWithinCareCapability(sevLvl) sevLvl = (careCapLvl - 1)
#define setOutsideCareCapability(sevLvl) sevLvl = careCapLvl

inline logCareCapability(careCapLvl) {
  printf("careCapability = %d\n", careCapLvl)
}

/*****************************************************************************/
/*                         Patient Severity Trend                            */
/*****************************************************************************/
byte trndSevLvl = INIT

inline logTrend(trndSevLvl) {
  printf("trendSeverity = %d\n", trndSevLvl)
}

/*****************************************************************************/
/*                    Behavior Model for Patient Severity                    */
/*****************************************************************************/
inline updatePatientSeverity(trndSevLvl, sevLvl) {
  if
  :: (isINIT(sevLvl) && isINIT(trndSevLvl)) -> 
     if
     :: true -> setSeverity(sevLvl, 0)
     :: true -> setSeverity(sevLvl, 1)
     :: true -> setSeverity(sevLvl, 2)
     fi 
  :: isWithinCareCapability(trndSevLvl) -> 
     if
     :: true -> setSeverity(sevLvl, 0)
     :: true -> setSeverity(sevLvl, 1)
     fi
  :: else -> 
     if
     :: true -> setSeverity(sevLvl, 1)
     :: true -> setSeverity(sevLvl, 2)
     fi
  fi
  setSeverity(trndSevLvl, sevLvl)
  logSeverity(sevLvl)
}

inline updatePatientMortality(trndSevLvl, sevLvl) {
  if
  :: !isWithinCareCapability(trndSevLvl) -> 
    setSeverity(sevLvl, EXPIRED)
  :: !isWithinCareCapability(sevLvl) ->
    setSeverity(sevLvl, EXPIRED)
  :: true
  fi
  logSeverity(sevLvl)
}

/*****************************************************************************/
/*                     Behavior Model for Severity Trend                     */
/*****************************************************************************/
inline updateSeverityTrend(trndSevLvl) {
  if
  :: true -> setWithinCareCapability(trndSevLvl)
  :: true -> setOutsideCareCapability(trndSevLvl)
  fi

  logTrend(trndSevLvl)
}

/*****************************************************************************/
/*                     Behavior Model for Doctor Orders                      */
/*****************************************************************************/
inline updateDoctorOrders(sevLvl, orders) {
  if
  :: isRequiresHospital(sevLvl) ->
    setHospital(orders)
  :: else ->
    if
      :: (sevLvl != 0) -> 
        setHomeCare(orders)
      :: (isNone(orders) && (sevLvl == 0)) ->
        setHomeCare(orders)
      :: else ->
        setDischarge(orders)
    fi
  fi
  logOrders(orders)
}
