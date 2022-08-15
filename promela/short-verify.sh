#!/bin/sh
# time cat 07-Apr-2021-Properties.txt | xargs verify.sh 07-Apr-2021-CWP-Class.pml 07-Apr-2021-BPMN.pml 07-Apr-2021-CWP-States.pml
#time cat 07-Apr-2021-Properties.txt | xargs verify.sh 26-Oct-2021-CWP-State.pml 26-Oct-2021-BPMN.pml 26-Oct-2021-CWP-LTL.pml

## 16-Feb-2022 Model with Conjunctions for States
#time cat 07-Apr-2021-Properties.txt | xargs verify.sh 16-Feb-2022-CWP-State.pml 16-Feb-2022-BPMN.pml 16-Feb-2022-CWP-LTL.pml

## 16-Feb-2022 Model with Disjunctions for States
#time cat 07-Apr-2021-Properties.txt | xargs verify.sh 16-Feb-2022-CWP-State-Disjunct-Edges.pml 16-Feb-2022-BPMN.pml 16-Feb-2022-CWP-LTL.pml


## 16-Feb-2022 Model with Orders Removed from Model
time cat 07-Apr-2021-Properties.txt | xargs verify.sh 16-Feb-2022-CWP-State-No-Orders.pml 16-Feb-2022-BPMN-No-Orders.pml 16-Feb-2022-CWP-LTL.pml
