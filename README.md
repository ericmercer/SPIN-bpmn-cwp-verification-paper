# Model Checking A Remote Monitoring Heath IT System for Patient Safety

Remote health-care that integrates human and machine intelligence for patient monitoring is an active area of research in health IT systems. These systems must take extra precautions to ensure safety since the patient is not in the direct supervision of the medical provider. This paper details the application of model checking to a remote COVID-19 patient monitoring system to prove the system ensures patient safety. The requirements for patient safety are formalized as a cognitive work problem that is translated to Linear Temporal Logic suitable for the SPIN model checker. A cognitive work problem is a computationally independent declarative model stating what a system must accomplish. The system itself is modeled with the Business Process Modeling Notation to capture the coordinated asynchronous and remote behaviors of the patient at home, the artificial intelligence in the cloud, and the medical providers. These two models with behavior models for vitals etc. are given to SPIN. SPIN proves the system preserves patient safety as defined in the cognitive work problem. This verification result complements conventional software evaluations and increases the safety and acceptance of such remote health IT systems.

# Contents of Repository

The top-level directory has images for the BPMN workflow of the PHware system for remote monitoring of COVID-19 positive patients at home. It also contains an image of the cognitive work problem that is being solved by the PHware BPMN workflow. That problem encodes, in a way that is actionable, the risk awareness for the patient. That cognitive work problem is the verification condition that the BPMN workflow model of the PHware system must meet.

The **paper** directory is a paper, formatted with LaTeX, explaining the entire verification process including the BPMN flow, the cognitive work problem it solves, and the resulting verification model. That verification model is written in Promela for the SPIN model checker. The cognitive work problem is captured in a set of LTL properties.

The **promela** directory is the actual Promela. It is divided into three files for convenience.
  1. *07-Apr-2021-BPMN.pml* is the actual BPMN workflow rendered as Promela
  2. *07-Apr-2021-CWP-Class.pml* is the global variables for the object state defined by the cognitive work problem
  3. *07-Apr-2021-CWP-States.pml* holds all the LTL properties derived from the transition diagram on the object state in the cognitive work problem.

The **promela** directory also includes a *verify.sh* script to combine the promela files and then run all the verification properties. These are listed in the *07-Apr-2021-Properties.txt* file. Here is the command to verify all properties using the script:

```bash
cat 07-Apr-2021-Properties.txt | xargs verify.sh 07-Apr-2021-CWP-Class.pml 07-Apr-2021-BPMN.pml 07-Apr-2021-CWP-States.pml
```

Alternatively, the *short-verify.sh* script runs the above with the add **time** command.

All the existential properties (ending with **Exists**) should result in an error. The error is the existential witness. All the other properties should pass with no errors. The output of the script includes not just the error report but the coverage summary of the processes and properties. The first two entries pertain to the clinician and patient-caregiver processes. There should never be uncovered states in these processes. The third entry is the property automata being verified. It is not unusual to have uncovered states here when there is no reported error as those states usually correlate with the error state.