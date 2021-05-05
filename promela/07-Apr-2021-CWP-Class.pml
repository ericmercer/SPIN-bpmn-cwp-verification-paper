/*****************************************************************************/
/*                            Doctors Orders                                 */
/*****************************************************************************/
mtype = {homeCare, hospital, discharge}
mtype orders = homeCare

#define isHomeCare(orders) (orders == homeCare)

#define setHomeCare(orders) orders = homeCare

#define isHospital(orders) (orders == hospital)

#define setHospital(orders) orders = hospital

#define isDischarge(orders) (orders == discharge)

#define setDischarge(orders) orders = discharge
 
inline logOrders(orders) {
  printf("orders = %e\n", orders)
}

//****************************************************************************/
/*                            Patient Severity                               */
/*****************************************************************************/
#define EXPIRED 255
byte severity = 0

#define setSeverity(severity, value) severity = value
#define isRequiresHospital(severity) (severity >= 2 && severity != EXPIRED)
#define isFatality(severity) (severity == EXPIRED)

inline logSeverity(severity) {
  printf("severity = %d\n", severity)
}

//****************************************************************************/
/*                      Patient Care Capability Level                        */
/*****************************************************************************/
byte careCapability = 2

#define setCareCapability(careCabapility, value) careCabapility = value
#define isWithinCareCapability(severity) (severity < careCapability)
#define setWithinCareCapability(severity) severity = (careCapability - 1)
#define setOutsideCareCapability(severity) severity = careCapability

inline logCareCapability(careCapability) {
  printf("careCapability = %d\n", careCabapility)
}

/*****************************************************************************/
/*                         Patient Severity Trend                            */
/*****************************************************************************/
byte trendSeverity = 0

inline logTrend(trendSeverity) {
  printf("trendSeverity = %d\n", trendSeverity)
}

/*****************************************************************************/
/*                                   Alert                                   */
/*****************************************************************************/
bool alert = false

#define isAlert(alert) (alert == true)

#define setAlert(alert) alert = true

#define clearAlert(alert) alert = false

inline logAlert(alert) {
  printf("alert = %d\n", alert)
}

/*****************************************************************************/
/*                                Exam Type                                  */
/*****************************************************************************/
mtype = {routine, urgent}
mtype examType = routine

#define isExamTypeRoutine(type) (type == routine)

#define setExamTypeRoutine(type) type = routine

#define isExamTypeUrgent(type) (type == urgent)

#define setExamTypeUrgent(type) type = urgent

inline logExamType(type) {
  printf("examType = %e\n", type)
}

/*****************************************************************************/
/*                                Exam Time                                  */
/*****************************************************************************/
mtype = {now, unscheduled, scheduled}
mtype examTime = unscheduled

#define isExamTimeNow(time) (time == now)

#define setExamTimeNow(time) time = now

#define isExamTimeUnscheduled(time) (time == unscheduled)

#define setExamTimeUnscheduled(time) time = unscheduled

#define isExamTimeScheduled(time) (time == scheduled)

#define setExamTimeScheduled(time) time = scheduled

inline logExamTime(time) {
  printf("examTime = %e\n", time)
}

/*****************************************************************************/
/*                     Behavior Model for Severity Trend                     */
/*****************************************************************************/
inline updateSeverityTrendAndAlert(alert, trendSeverity, severity) {
  if
  :: true -> setWithinCareCapability(trendSeverity)
  :: true -> setOutsideCareCapability(trendSeverity)
  fi

  logTrend(trendSeverity)
  
  if
  :: true -> setAlert(alert)
  :: true
  fi

  logAlert(alert)
  }

/*****************************************************************************/
/*                    Behavior Model for Patient Severity                    */
/*****************************************************************************/
inline updatePatientSeverity(trendSeverity, severity) {
  if
  :: isWithinCareCapability(trendSeverity) -> 
     if
     :: true -> setSeverity(severity, 0)
     :: true -> setSeverity(severity, 1)
     fi
  :: !isWithinCareCapability(trendSeverity) -> setSeverity(severity, 2)
  :: true
  fi
  setSeverity(trendSeverity, severity)
  logSeverity(severity)
}

inline updatePatientMortality(trendSeverity, severity) {
  if
  :: !isWithinCareCapability(trendSeverity) -> 
    setSeverity(severity, EXPIRED)
  :: !isWithinCareCapability(severity) ->
    setSeverity(severity, EXPIRED)
  :: true
  fi
  logSeverity(severity)
}

/*****************************************************************************/
/*                     Behavior Model for Doctor Orders                      */
/*****************************************************************************/
inline updateDoctorOrders(severity, orders) {
  if
  :: isRequiresHospital(severity) ->
    setHospital(orders)
  :: else ->
    if
      :: (severity != 0) -> 
        setHomeCare(orders)
      :: else -> 
        setDischarge(orders)
    fi
  fi
  logOrders(orders)
}

/*****************************************************************************/
/*                       Behavior Model for Exam Type                        */
/*****************************************************************************/
inline updateExamType(alert, trendSeverity, severity, examType) {
  clearAlert(alert)
  if
  :: (isExamTypeRoutine(examType) && !isWithinCareCapability(trendSeverity)) ->
    if
    :: true -> setExamTypeUrgent(examType)
    :: true
    fi
  :: else
  fi
  logExamType(examType)
}

/*****************************************************************************/
/*                       Behavior Model for Exam Time                        */
/*****************************************************************************/
inline setExamTimeIfScheduled(time) {
  if
  :: isExamTimeScheduled(time) ->
    setExamTimeNow(time)
  :: true
  fi
  logExamTime(time)
}