# Model Checking A Remote Monitoring Heath IT System for Patient Safety

Remote health-care that integrates human and machine intelligence for patient monitoring is an active area of research in health IT systems. These systems must take extra precautions to ensure safety since the patient is not in the direct supervision of the medical provider. This paper details the application of model checking to a remote COVID-19 patient monitoring system to prove the system ensures patient safety. The requirements for patient safety are formalized as a cognitive work problem that is translated to Linear Temporal Logic suitable for the SPIN model checker. A cognitive work problem is a computationally independent declarative model stating what a system must accomplish. The system itself is modeled with the Business Process Modeling Notation to capture the coordinated asynchronous and remote behaviors of the patient at home, the artificial intelligence in the cloud, and the medical providers. These two models with behavior models for vitals etc. are given to SPIN. SPIN proves the system preserves patient safety as defined in the cognitive work problem. This verification result complements conventional software evaluations and increases the safety and acceptance of such remote health IT systems.

# Contents of Repository

The top-level directory has images for the BPMN workflow of the PHware system for remote monitoring of COVID-19 positive patients at home. It also contains an image of the cognitive work problem that is being solved by the PHware BPMN workflow. That problem encodes, in a way that is actionable, the risk awareness for the patient. That cognitive work problem is the verification condition that the BPMN workflow model of the PHware system must meet.

The **paper** directory is a paper, formatted with LaTeX, explaining the entire verification process including the BPMN flow, the cognitive work problem it solves, and the resulting verification model. That verification model is written in Promela for the SPIN model checker. The cognitive work problem is captured in a set of LTL properties.

The **promela** directory is the actual Promela. It is divided into three files for convenience.
  1. *<date>-BPMN.pml* is the actual BPMN workflow rendered as Promela
  2. *<date>-CWP-State.pml* is the global variables for the object state defined by the cognitive work problem
  3. *<date>-CWP-LTL.pml* holds all the LTL properties derived from the transition diagram on the object state in the cognitive work problem.

The **promela** directory also includes a *verify.sh* script to combine the promela files and then run all the verification properties. These are listed in the *07-Apr-2021-Properties.txt* file. Here is the command to verify all properties using the script for the model from **07-Apr-2021**:

```bash
cat 07-Apr-2021-Properties.txt | xargs verify.sh 07-Apr-2021-CWP-State.pml 07-Apr-2021-BPMN.pml 07-Apr-2021-CWP-LTL.pml
```

Alternatively, the *short-verify.sh* script runs the above with the added **time** command. That script is currently set to use the most recent model dated **16-Feb-2022**.

All the existential properties (ending with **Exists**) should result in an error. The error is the existential witness. All the other properties should pass with no errors. The output of the script includes not just the error report but the coverage summary of the processes and properties. The first two entries pertain to the clinician and patient-caregiver processes. There should never be uncovered states in these processes. The third entry is the property automata being verified. It is not unusual to have uncovered states here when there is no reported error as those states usually correlate with the error state.

# 07-Apr-2021 Model

This version of the model is based on a more complex workflow while the CWP is largely the same. The debug output is less rich. States or solely defined by predicates making it harder to know which state is current active.

# 26-Oct-2021 Model

Simplifies the environment model. Adds a global variable for each state with an `updateState` function to set the global state variables when `sevNeed`, `trndSevNeed`, or `orders` change. Richer debug information in general.

The **SYSCON 2022** paper uses this version of the model but with a notable change. The paper does have a typo when describing the `updatePatientSeverity` environment macro. The choice can not be truly *random* but must rather only `setOutsideHomeCare` if the `trndSevNeed > homeCare` holds. Without this strengthening on the environment, `InitStateEdges` and `ptInAppropriateHomeCareEdges` fail verification moving to the `pt expired` state incorrectly.

# 16-Feb-2022 Model

Restructured Promela model that adds more logging for debug. It also simplifies the environment model call specific update functions for each task. The environment updates are thus specialized to each task. The structure should make auto-generation of the Promela file easier because the user can add code to only the tasks that need to update the environment, but more specifically, that code is contained in one `inline` macro for the task. Calling a single inline macro has less impact of the BPMN code structure. 

There are two state files for the model as well. The paper is **not** clear on how the states are actually defined. The paper text conjuncts over the input transitions, but that same text gives an example where it disjuncts over the incoming transitions. The intent of the conjunct is actually an intersection: in other words the meet on the lattice where the commonality of the incoming transitions hold. 

But since the example makes it ambiguous at best, there is a second state file that actually disjuncts over the inputs, so any one (or more) of the input conditions must be true. Both versions verify. But there is an obvious lack of clarity in how the states should be defined.

# Defining the CWP States for Verification

There are two ways to define the states in the CWP.
The first intersects over the incoming transitions to find what is commonly true between all those transitions. It then excludes from that, anything that would make an outgoing transition true.

The second simply unions over the incoming transitions, at least one must be true, and it then excludes from that, anything that would make an outgoing transition true.

It is not yet clear which of these should be preferred. The `SYSCON 2022` paper is ambiguous at best.