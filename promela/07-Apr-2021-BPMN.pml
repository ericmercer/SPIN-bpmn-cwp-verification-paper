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
/*                          Behavior Model Alert                             */
/*****************************************************************************/
inline updateAlert(alert) {
  if
  :: true -> setAlert(alert)
  :: true
  fi

  logAlert(alert)
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
/*                       Behavior Model for Exam Type                        */
/*****************************************************************************/
inline updateExamType(trendSeverity, examType) {
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

/*****************************************************************************/
/*                         Clinician Flow Places                             */
/*****************************************************************************/
bit clinicianEnd61 = 0
bit clinicianEndPtExpired = 0
bit clinicianRecv00In0 = 0
bit clinicianRecv00In1 = 0
bit clinicianRecv01 = 0
bit clinicianRecv01Vitals = 0
bit clinicianTask01In0 = 0
bit clinicianTask01In1 = 0
bit clinicianTask01In2 = 0
bit clinicianTask02 = 0
bit clinicianTask03 = 0
bit clinicianTask07a = 0
bit clinicianTask07b = 0
bit clinicianTask08aIn0 = 0
bit clinicianTask08aIn1 = 0
bit clinicianTask08bIn0 = 0
bit clinicianTask08bIn1 = 0
bit clinicianWait00 = 0
bit clinicianXor5 = 0
bit clinicianXor4 = 0
bit clinicianXor8 = 0
bit clinicianXor9 = 0
bit clinicianXor10 = 0
bit clinicianXor11In0 = 0
bit clinicianXor11In1 = 0
bit clinicianXor11In2 = 0
bit clinicianXor11In3 = 0

/*****************************************************************************/
/*                         Home Care Flow Places                             */
/*****************************************************************************/
bit homeCareFlowEnd196 = 0
bit homeCareFlowEndPtExpired = 0
bit homeCareFlowRecv00 = 0
bit homeCareFlowSend00 = 0
bit homeCareFlowTask04 = 0
bit homeCareFlowTask05In00 = 0
bit homeCareFlowTask05In01 = 0
bit homeCareFlowXor6 = 0
bit homeCareFlowXor7 = 0

/*****************************************************************************/
/*                             Token Management                              */
/*****************************************************************************/
#define hasToken(place) (place != 0)

#define putToken(place) place = 1

#define consumeToken(place) place = 0

#define hasToken2Xor(place0, place1) \
  ((place0 != 0 && place1 == 0) || (place0 == 0 && place1 != 0))


#define hasToken3Xor(place0, place1, place2)         \
  (                                                  \
       (place0 != 0 && place1 == 0 && place2 == 0)   \
    || (place0 == 0 && place1 != 0 && place2 == 0)   \
    || (place0 == 0 && place1 == 0 && place2 != 0)   \
  )

#define hasToken4Xor(place0, place1, place2, place3)                \
  (                                                                 \
       (place0 != 0 && place1 == 0 && place2 == 0 && place3 == 0)   \
    || (place0 == 0 && place1 != 0 && place2 == 0 && place3 == 0)   \
    || (place0 == 0 && place1 == 0 && place2 != 0 && place3 == 0)   \
    || (place0 == 0 && place1 == 0 && place2 == 0 && place3 != 0)   \
  )

#define hasToken2And(place0, place1) (place0 != 0 && place1 != 0)

/*****************************************************************************/
/*                          Clinician Workflow                               */
/*****************************************************************************/
active proctype clinician() {
  putToken(clinicianTask01In0)
  do
  :: hasToken(clinicianEnd61) ->
    atomic {
      break
    }
  :: hasToken(clinicianEndPtExpired) ->
    atomic {
      break
    }
  :: hasToken(homeCareFlowEndPtExpired) ->
    atomic {
      break
    }
  :: hasToken2And(clinicianRecv00In0, clinicianRecv00In1) ->
    atomic {
      consumeToken(clinicianRecv00In0)
      consumeToken(clinicianRecv00In1)
      putToken(clinicianTask01In1)
    }
   :: hasToken2And(clinicianRecv01, clinicianRecv01Vitals) ->
    atomic {
      consumeToken(clinicianRecv01)
      consumeToken(clinicianRecv01Vitals)
      putToken(clinicianXor8)
    }
  :: hasToken3Xor(clinicianTask01In0, clinicianTask01In1, clinicianTask01In2) ->
    atomic {
      consumeToken(clinicianTask01In0)
      consumeToken(clinicianTask01In1)
      consumeToken(clinicianTask01In2)
      consumeToken(clinicianRecv01Vitals)
      printf("01- Doctor or Nurse examine pt\n")
      updatePatientSeverity(trendSeverity, severity)
      updateDoctorOrders(severity, orders)
      setExamTimeUnscheduled(examTime)
      setExamTypeRoutine(examType)
      putToken(clinicianXor5)
    }
  :: hasToken(clinicianTask02) ->
    atomic {
      consumeToken(clinicianTask02)
      printf("02- Doctor orders home care with PHWARE and 4-7 day routine exam\n")
      setExamTypeRoutine(examType)
      putToken(clinicianRecv01)
      putToken(homeCareFlowRecv00)
    }
  :: hasToken(clinicianTask03) ->
    atomic {
      consumeToken(clinicianTask03)
      printf("03- Doctor admit pt to hospital or ICU care\n")
      updatePatientMortality(trendSeverity, severity)
      putToken(clinicianXor4)
    }
  :: hasToken(clinicianTask07a) ->
    atomic {
      consumeToken(clinicianTask07a)
      printf("07a- Doc-Nurse review alert, vitals and exam schedule\n")
      updateExamType(trendSeverity, examType)
      setExamTimeIfScheduled(examTime)
      putToken(clinicianXor9)
    }
  :: hasToken(clinicianTask07b) ->
    atomic {
      consumeToken(clinicianTask07b)
      printf("07b- Doc-Nurse review vitals and exam schedule\n")
      updateExamType(trendSeverity, examType)
      setExamTimeIfScheduled(examTime)
      putToken(clinicianXor10)
    }
  :: hasToken2Xor(clinicianTask08aIn0, clinicianTask08aIn1) ->
    atomic {
      consumeToken(clinicianTask08aIn0)
      consumeToken(clinicianTask08aIn1)
      printf("08a- Scheduler sets up urgent exam and informs patient\n")
      setExamTimeNow(examTime)
      putToken(clinicianXor11In1)
    }
  :: hasToken2Xor(clinicianTask08bIn0, clinicianTask08bIn1) ->
    atomic {
      consumeToken(clinicianTask08bIn0)
      consumeToken(clinicianTask08bIn1)
      printf("08b- Scheduler schedules routine exam and informs patient\n")
      if
      :: true -> setExamTimeScheduled(examTime)
      :: true
      fi
      putToken(clinicianXor11In2)
    }
  :: hasToken(clinicianWait00) ->
    atomic {
      consumeToken(clinicianWait00)
      putToken(clinicianTask07b)
    }
  :: hasToken(clinicianXor5) ->
    atomic {
      consumeToken(clinicianXor5)
      if
      :: isHospital(orders) ->
        putToken(clinicianTask03)
      :: isDischarge(orders) ->
        putToken(clinicianEnd61)
      :: isHomeCare(orders) ->
        putToken(clinicianTask02)
      fi
    }
  :: hasToken(clinicianXor4) ->
    atomic {
      consumeToken(clinicianXor4)
      if
      :: isFatality(severity) ->
        putToken(clinicianEndPtExpired)
      :: else ->
        putToken(clinicianTask01In2)
      fi
    }
  :: hasToken(clinicianXor8) ->
    atomic {
      consumeToken(clinicianXor8)
      if
      :: isAlert(alert) ->
        putToken(clinicianTask07a)
      :: else ->
        putToken(clinicianWait00)
      fi
    }
  :: hasToken(clinicianXor9) ->
    atomic {
      consumeToken(clinicianXor9)
      if 
      :: isExamTimeNow(examTime) ->
        putToken(clinicianXor11In3)
      :: else ->
        if
        :: isExamTypeUrgent(examType) ->
          putToken(clinicianTask08aIn1)
        :: isExamTypeRoutine(examType) && isExamTimeUnscheduled(examTime) ->
          putToken(clinicianTask08bIn0)
        :: else ->
          putToken(clinicianRecv01)
        fi
      fi
    }
  :: hasToken(clinicianXor10) ->
    atomic {
      consumeToken(clinicianXor10)
      if 
      :: isExamTimeNow(examTime) ->
        putToken(clinicianXor11In0)
      :: else ->
        if
        :: isExamTypeUrgent(examType) ->
          putToken(clinicianTask08aIn0)
        :: isExamTypeRoutine(examType) && isExamTimeUnscheduled(examTime) ->
          putToken(clinicianTask08bIn1)
        :: else ->
          putToken(clinicianRecv01)
        fi
      fi
    }
  :: hasToken4Xor(clinicianXor11In0, clinicianXor11In1, clinicianXor11In2, clinicianXor11In3) ->
    atomic {
      consumeToken(clinicianXor11In0)
      consumeToken(clinicianXor11In1)
      consumeToken(clinicianXor11In2)
      consumeToken(clinicianXor11In3)
      if
      :: isExamTimeNow(examTime) ->
        putToken(clinicianRecv00In0)
      :: else -> 
        putToken(clinicianRecv01)
      fi
    }
  od
}

/*****************************************************************************/
/*                           Home Care Workflow                              */
/*****************************************************************************/
active proctype homeCareFlow() {
  do
  :: (hasToken(clinicianEnd61) || hasToken(clinicianEndPtExpired)) ->
    atomic {
      break
    }
  :: hasToken(homeCareFlowEnd196) ->
    atomic {
      consumeToken(homeCareFlowEnd196)
    }
  :: hasToken(homeCareFlowEndPtExpired) ->
    atomic {
      break
    }
  :: hasToken(homeCareFlowRecv00)
    atomic {
      consumeToken(homeCareFlowRecv00)
      putToken(homeCareFlowTask04)
    }
  :: hasToken(homeCareFlowSend00) ->
    atomic {
      consumeToken(homeCareFlowSend00)
      putToken(clinicianRecv00In1)
      putToken(homeCareFlowEnd196)
    }
  :: hasToken(homeCareFlowTask04)
    atomic {
      consumeToken(homeCareFlowTask04)
      printf("04- Pt or care-giver get-install Phware\n")
      putToken(homeCareFlowTask05In00)
    }
  :: hasToken2Xor(homeCareFlowTask05In00, homeCareFlowTask05In01) ->
    atomic {
      consumeToken(homeCareFlowTask05In00)
      consumeToken(homeCareFlowTask05In01)
      printf("05- Pt or care-giver follow order to record vitals\n")
      updatePatientMortality(trendSeverity, severity)
      updateSeverityTrend(trendSeverity)
      updateAlert(alert)
      putToken(clinicianRecv01Vitals)
      putToken(homeCareFlowXor6)
    }
  :: hasToken(homeCareFlowXor7) ->
    atomic {
      consumeToken(homeCareFlowXor7)
      if
      :: isExamTimeNow(examTime) ->
        putToken(homeCareFlowSend00)
      :: else ->
        putToken(homeCareFlowTask05In00)
      fi
    }
  :: hasToken(homeCareFlowXor6) ->
    atomic {
      consumeToken(homeCareFlowXor6)
      if
      :: isFatality(severity) ->
        putToken(homeCareFlowEndPtExpired)
      :: else ->
        putToken(homeCareFlowXor7)
      fi
    }
  od
}
