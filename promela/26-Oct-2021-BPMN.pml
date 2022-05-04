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
/*                                Exam Time                                  */
/*****************************************************************************/
mtype = {unscheduled, scheduled, now}
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
/*                         Clinician Flow Places                             */
/*****************************************************************************/
bit clinicianEndPtDischarged = 0
bit clinicianEndPtDischarged1 = 0
bit clinicianEndPtExpired = 0
bit clinicianRecv00In0 = 0
bit clinicianRecv00In1 = 0
bit clinicianRecv01 = 0
bit clinicianRecv01Vitals = 0
bit clinicianStartPtPlusCOVID = 0
bit clinicianTask01In0 = 0
bit clinicianTask01In1 = 0
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
/*                          AI Cloud Server Flow                             */
/*****************************************************************************/
bit aICloudServerStart113 = 0
bit aICloudServerTask06 = 0
bit aICloudServerEnd232 = 0

/*****************************************************************************/
/*                           Patient Flow Places                             */
/*****************************************************************************/
bit patientEnd196 = 0
bit patientEndPtExpired1 = 0
bit patientStart170 = 0
bit patientSend00 = 0
bit patientTask04 = 0
bit patientTask05In00 = 0
bit patientTask05In01 = 0
bit patientXor6 = 0
bit patientXor7 = 0

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
inline clinicianTask01UpdateState() {
  assert(!meetsDischargeCriteria(sevNeed, orders) && !isExpired(sevNeed))
  
  if
  :: true -> setWithinHomeCare(sevNeed)
    if
    :: (!isInit(trndSevNeed) && isOutsideHomeCare(trndSevNeed)) -> 
      setHomeCarePlus(orders)
    :: else -> setHomeCare(orders)
    fi
  :: true -> setOutsideHomeCare(sevNeed)
             setHospital(orders)
  :: (!isInit(sevNeed)) -> setDischargeCriteria(sevNeed, orders)
  fi 
  trndSevNeed = sevNeed
  updateState()
}

inline clinicianTask03UpdateState() {
  assert(!meetsDischargeCriteria(sevNeed, orders) && !isExpired(sevNeed))
  if
  :: true -> setExpired(sevNeed)
  :: true -> setDischargeCriteria(sevNeed, orders)
  fi 
  trndSevNeed = sevNeed
  updateState()
}

inline clinicianTask07aUpdateState() {
  clearAlert(alert)
  if
  :: isExamTimeScheduled(examTime) ->
    setExamTimeNow(examTime)
  :: true
  fi
}

inline clinicianTask07bUpdateState() {
  clearAlert(alert)
  if
  :: isExamTimeScheduled(examTime) ->
    setExamTimeNow(examTime)
  :: true
  fi
}

inline clinicianTask08aUpdateState() {
  setExamTimeNow(examTime)
}

inline clinicianTask08bUpdateState() {
  setExamTimeScheduled(examTime)
}

active proctype clinician() {
  putToken(clinicianStartPtPlusCOVID)
  do
  :: // ADDITIONAL: Patient Expired at Home
    atomic {
      hasToken(patientEndPtExpired1) ->
      break
    }

  :: // Clinician pt discharged
    atomic {
      hasToken(clinicianEndPtDischarged) ->
      break
    }

  :: // Cinician pt discharged 1
    atomic {
      hasToken(clinicianEndPtDischarged1) ->
      break
    }


  :: // Clinician pt expired
    atomic {
      hasToken(clinicianEndPtExpired) ->
      break
    }

  :: // Seconds catch ex pt
    atomic {
      hasToken2And(clinicianRecv00In0, clinicianRecv00In1) ->
      consumeToken(clinicianRecv00In0)
      consumeToken(clinicianRecv00In1)
      putToken(clinicianTask01In1)
    }
  
  :: // Seconds catch AI
    atomic {
      hasToken2And(clinicianRecv01, clinicianRecv01Vitals) ->
      consumeToken(clinicianRecv01)
      consumeToken(clinicianRecv01Vitals)
      putToken(clinicianXor8)
    }

  :: // Clinician pt + COVID-19
    atomic {
      hasToken(clinicianStartPtPlusCOVID) ->
      consumeToken(clinicianStartPtPlusCOVID)
      putToken(clinicianTask01In0)
    }

  
  :: // Clinician Task 01
    atomic {
      hasToken2Xor(clinicianTask01In0, clinicianTask01In1) ->
      consumeToken(clinicianTask01In0)
      consumeToken(clinicianTask01In1)
      printf("01- Doctor or Nurse examine pt\n")
      clinicianTask01UpdateState()
      putToken(clinicianXor5)
    }

  :: // Clinician Task 02
    atomic {
      hasToken(clinicianTask02) ->
      consumeToken(clinicianTask02)
      printf("02- Doctor orders home care with PHWARE and 4-7 day routine exam\n")
      putToken(clinicianRecv01)
      putToken(patientStart170)
    }

  :: // Clinician Task 03
    atomic {
      hasToken(clinicianTask03) ->
      consumeToken(clinicianTask03)
      printf("03- Doctor admit pt to hospital or ICU care\n")
      clinicianTask03UpdateState()
      putToken(clinicianXor4)
    }

  :: // Clinician Task 07a
    atomic {
      hasToken(clinicianTask07a) ->
      consumeToken(clinicianTask07a)
      printf("07a- Doc-Nurse review alert, vitals and exam schedule\n")
      clinicianTask07aUpdateState()
      putToken(clinicianXor9)
    }

  :: // Clinician Task 07b
    atomic {
      hasToken(clinicianTask07b) ->
      consumeToken(clinicianTask07b)
      printf("07b- Doc-Nurse review vitals and exam schedule\n")
      clinicianTask07bUpdateState()
      putToken(clinicianXor10)
    }

  // clinicianTask08aIn0: from Xor10
  // clinicianTask08aIn1: from Xor09
  :: // Clinician Task 08a
    atomic {
      hasToken2Xor(clinicianTask08aIn0, clinicianTask08aIn1) ->
      consumeToken(clinicianTask08aIn0)
      consumeToken(clinicianTask08aIn1)
      printf("08a- Scheduler sets up urgent exam and informs patient\n")
      clinicianTask08aUpdateState()
      putToken(clinicianXor11In1)
    }

  // clinicianTask08bIn0: from Xor09
  // clinicianTask08bIn1: from Xor10
  :: // Clinician Task 08b
    atomic {
      hasToken2Xor(clinicianTask08bIn0, clinicianTask08bIn1) ->
      consumeToken(clinicianTask08bIn0)
      consumeToken(clinicianTask08bIn1)
      printf("08b- Scheduler schedules routine exam and informs patient\n")
      clinicianTask08bUpdateState()
      putToken(clinicianXor11In2)
    }

  :: // Clinicians Hours Delay
    atomic {
      hasToken(clinicianWait00) ->
      consumeToken(clinicianWait00)
      putToken(clinicianTask07b)
    }

  :: // Clinician Xor4
    atomic {
      hasToken(clinicianXor4) ->
      consumeToken(clinicianXor4)
      if
      :: isExpired(sevNeed) ->
        putToken(clinicianEndPtExpired)
      :: (meetsDischargeCriteria(sevNeed, orders)) ->
        putToken(clinicianEndPtDischarged1)
      :: else -> 
        printf("ERROR: nothing enabled Xor4\n")
        assert(false)
      fi
    }

  :: // Clinician Xor5
    atomic {
      hasToken(clinicianXor5) ->
      consumeToken(clinicianXor5)
      if
      :: isOutsideHomeCare(sevNeed) ->
        putToken(clinicianTask03)
      :: meetsDischargeCriteria(sevNeed, orders) ->
        putToken(clinicianEndPtDischarged)
      :: isWithinHomeCare(sevNeed) ->
        putToken(clinicianTask02)
      :: else ->
        printf("ERROR: nothing enabled Xor5\n")
        assert(false)
      fi
    }

  :: // Clinician Xor8
    atomic {
      hasToken(clinicianXor8) ->
      consumeToken(clinicianXor8)
      if
      :: isAlert(alert) ->
        putToken(clinicianTask07a)
      :: else ->
        putToken(clinicianWait00)
      fi
    }
  
  :: // Clinician Xor9
    atomic {
      hasToken(clinicianXor9) ->
      consumeToken(clinicianXor9)
      if 
      :: isExamTimeNow(examTime) ->
        putToken(clinicianXor11In3)
      :: else ->
        if
        :: (isOutsideHomeCare(trndSevNeed)) ->
          putToken(clinicianTask08aIn1)
        :: (isWithinHomeCare(trndSevNeed) && isExamTimeUnscheduled(examTime)) ->
          putToken(clinicianTask08bIn0)
        :: (isWithinHomeCare(trndSevNeed)) ->
          putToken(clinicianRecv01)
        :: else ->
          printf("ERROR: nothing enabled Xor9\n")
          assert(false)
        fi
      fi
    }

  :: // Clinician Xor10
    atomic {
      hasToken(clinicianXor10) ->
      consumeToken(clinicianXor10)
      if 
      :: isExamTimeNow(examTime) ->
        putToken(clinicianXor11In0)
      :: else ->
        if
        :: (isOutsideHomeCare(trndSevNeed)) ->
          putToken(clinicianTask08aIn0)
        :: (isWithinHomeCare(trndSevNeed) && isExamTimeUnscheduled(examTime)) ->
          putToken(clinicianTask08bIn1)
        :: isWithinHomeCare(trndSevNeed) ->
          putToken(clinicianRecv01)
        :: else ->
          printf("ERROR: nothing enabled Xor10\n")
          assert(false)
        fi
      fi
    }

  :: // Clinician Xor11
    atomic {
      hasToken4Xor(clinicianXor11In0, clinicianXor11In1, clinicianXor11In2, 
        clinicianXor11In3) ->
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
/*                          AI Cloud Server Workflow                         */
/*****************************************************************************/
inline aICloudServerTask06UpdateState() {
  if
  :: true -> setWithinHomeCare(trndSevNeed)
  :: true -> setOutsideHomeCare(trndSevNeed)
    if
    :: true -> setAlert(alert)
    :: true
    fi
  fi
  updateState()
}

active proctype aICloudServer() {
  do
  :: // ADDITIONAL: expired are discharged
    atomic {
      hasToken4Xor(clinicianEndPtDischarged, clinicianEndPtDischarged1,
        clinicianEndPtExpired, patientEndPtExpired1) ->
      break
    }
  :: // AI Cloud Server Start113 
    atomic { 
      hasToken(aICloudServerStart113) -> 
      consumeToken(aICloudServerStart113)
      putToken(aICloudServerTask06)
    }

  :: // AI Cloud Server Task 06 
    atomic {
      hasToken(aICloudServerTask06) ->
      consumeToken(aICloudServerTask06)
      printf("06 - PDA analyze vitals\n")
      aICloudServerTask06UpdateState()
      putToken(clinicianRecv01Vitals)
      putToken(aICloudServerEnd232)
    }
  
  :: // AI Cloud Server End232
    atomic {
      hasToken(aICloudServerEnd232) ->
      consumeToken(aICloudServerEnd232)
    }
  od
}

/*****************************************************************************/
/*                        Patient - caregiver Workflow                       */
/*****************************************************************************/
inline patientTask06UpdateState() {
  if
  :: (isOutsideHomeCare(trndSevNeed)) -> 
    setExpired(sevNeed)
  :: true
  fi
  updateState()
}

active proctype patient() {
  do
  :: // ADDITIONAL: expired or discharged
    atomic {
      hasToken3Xor(clinicianEndPtDischarged, clinicianEndPtDischarged1, 
        clinicianEndPtExpired) ->
      break
    }

  :: // Patient End196
    atomic {
      hasToken(patientEnd196) ->
      consumeToken(patientEnd196)
    }

  :: // Patient pt expired 1
    atomic {
      hasToken(patientEndPtExpired1) ->
      break
    }

  :: // Patient Start170
    atomic {
      hasToken(patientStart170) ->
      consumeToken(patientStart170)
      putToken(patientTask04)
    }

  :: // Patient seconds throw pt 
    atomic {
      hasToken(patientSend00) ->
      consumeToken(patientSend00)
      putToken(clinicianRecv00In1)
      putToken(patientEnd196)
    }

  :: // Patient Task 04
    atomic {
      hasToken(patientTask04) ->
      consumeToken(patientTask04)
      printf("04- Pt or care-giver get-install Phware\n")
      putToken(patientTask05In00)
    }

  :: // Patient Task 05
    atomic {
      hasToken2Xor(patientTask05In00, patientTask05In01) ->
      consumeToken(patientTask05In00)
      consumeToken(patientTask05In01)
      printf("05- Pt or care-giver follow order to record vitals\n")
      patientTask06UpdateState()
      putToken(aICloudServerStart113)
      putToken(patientXor6)
    }

  :: // Patient Xor6
    atomic {
      hasToken(patientXor6) ->
      consumeToken(patientXor6)
      if
      :: isExpired(sevNeed) ->
        putToken(patientEndPtExpired1)
      :: else ->
        putToken(patientXor7)
      fi
    }
  
  :: // Patient Xor7
    atomic {
      hasToken(patientXor7) ->
      consumeToken(patientXor7)
      if
      :: isExamTimeNow(examTime) ->
        putToken(patientSend00)
      :: else ->
        putToken(patientTask05In00)
      fi
    } 
  od
}
