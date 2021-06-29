# Response

**Limit:** 500 words

Thank you for the reviews. They are super helpful. Formal verification is specialized and often requires a high-level of domain expertise for any practical application, and venues such as MODELS are critical to helping formal verification researchers create useable tools for model based engineering and to helping researchers not in formal verification understand its value and limitations. I would enjoy very much having an opportunity to visit more about the manuscript and to address in depth, and in person, the questions and comments from the reviews. I find that opportunity exciting and constructive for all involved.  

Regarding 1) The source CWP model is the specification, created by domain experts, and assumed to be correct. The work in this paper is to verify whether or not a given workflow implements the CWP. That said, the act of verifying that a workflow implements a CWP yields significant insights about both. For example, in an earlier version of the CWP, SPIN found a trace through the workflow where the patient expires while in appropriate home care, which, as noted in the review, is not allowed by the CWP. The error was in the CWP, and not because of the missing transition, but rather because the meaning of appropriate home care was not precise. It omitted information about trending severity that would indicate an elevated risk. The domain experts reviewed and approved changes to the transition conditions in the CWP, and SPIN then verified that the workflow preserved the property that patients only expire in elevated risk or in the hospital under those changed conditions. The very act of verifying the workflow against the CWP, even assuming the CWP is correct, yields important insights that are easily missed by manual inspection with domain experts.

Regarding 2) SPIN establishes if the Promela and LTL are faithful renditions of their graphical counterparts after manual inspection. The Promela is written in a way that the counter-example can be directly mapped back to the graphical workflow and CWP.  When SPIN finds a counter-example, the counter-example is examined in the context of the graphical models in much the same way a failed unit test is debugged in the context of the actual source code. Indeed, early on, a few failed verification runs were a result of typos in the manual translation to Promela. To further gain confidence in the Promela model, additional properties were created that should fail and should pass if the Promela model is a faithful rendition of the graphical workflow. These can be understood as unit tests. 

Regarding 3) Scalability is model specific and is not an issue in this model because of the synchronization points between the swim lanes limiting concurrency, the small number of tasks in the workflow that affect the shared global state, and the relatively few points of non-determinism in the environment model. In general, highly concurrent systems, with a lot of non-determinism, that update the shared global state in many places, are less likely to be tractable in SPIN. The size of the LTL formulas also affects scalability but the translation of the CWP to LTL in this manuscript is done in a way to mitigate that affect. That said, scalability is something that can be explored after the process is automated and more case studies exist.

Regarding determinism on gates in the graphical model: not all gates need be deterministic, and it is to the workflow modeler to make that decision. The verification takes what is given and lets SPIN find violations, which can then be debugged by the workflow modeler to isolate the fault.

Regarding date-race: SPIN finds all data-race regardless if it is a r-w race in global state or message race at an end point. SPIN doesn't miss anything allowed in the model (for better or for worse).

# Reviewer question for Response

Reviewers specifically want these addressed in the response:

  1) How do we know the source CWP model is correct (e.g., that there isn't a G transition missing from "Pt in appropriate home care" to "Pt expired")?
  2) How are the manually-derived formal models (LTL, Promela) validated? Model checking helps check one against the other, but is the same people are involve they may contain the same issues.
  3) Why isn't scalability a problem? Because the CWP is simple? Because the properties are simple? Scalability is typically a challenge for model checking so some comments would be helpful here.

If room affords, other questions worth answering:

  * It is unclear whether the conditions on gates are actually deterministic (and ideally exhaustive). Is this an issue?

  * Does the use of global variables (section IV) prevent the detection of a category of errors what would be visible with the encoding of messages (e.g., race conditions)?

# Summary of Reviews

More background is need to explain formal verification, model checking, and the role of model checking in model based engineering as a means to understand the model itself---model based engineering is only as useful as the analysis tools provided to understand the model. Manual reasoning is not sufficient for complex concurrent models.

Need a discussion of the many types of errors that were discovered in the workflow and the CWP in order to show the value of the model checker in understanding both the property and the workflow model itself---is is a critical cool for any workflow modeling paradigm (and an important complement to simulation).

Need a discussion of related work with the limitations of model checking workflows against cognitive work problems. Add Besnard, V., Teodorov, C., Jouault, F., Brun, M., & Dhaussy, P. (2019, September). Verifying and monitoring UML models with observer automata: a transformation-free approach. In 2019 ACM/IEEE 22nd International Conference on Model Driven Engineering Languages and Systems (MODELS) (pp. 161-171). IEEE. Add M. Sharbaf, B. Zamani and B. T. Ladani, "Towards automatic generation of formal specifications for UML consistency verification," 2015 2nd International Conference on Knowledge-Based Engineering and Innovation (KBEI), 2015, pp. 860-865, doi: 10.1109/KBEI.2015.7436156.

# Review 1

**SCORE:** -1 (weak reject)

**Overall Summary**: The paper details the model checking of a remote patient monitoring system- Bionous PHware. This work aims to prove that the system preserves patient safety by formalizing the safety requirements in a cognitive work problem and translating it to Linear Temporal Logic properties. The complex model incorporates workflows for clinicians, AI cloud services, and patient-caregivers. This workflow is translated to Promela. The system is evaluated with the help of the SPIN model checker that checks if the system acts appropriately regarding risk awareness. 

Overall Evaluation: The paper addresses one of the relevant topics in both modeling and health IT systems. Although much work has been done that focuses on patient safety in remote health IT, this research is novel. It focuses on modeling a remote health IT model by translating the cognitive work problem into LTL and then using the SPIN model to evaluate the system. However, I think this paper has much room for improvement.

**Strengths**:

  * Timely Research

**Weakness**:

  * Weak representation of the proposed approach.
  * No discussion about the importance of the research in the industry (one of the requirements for P&I track).
  * Does not justify the negative findings (mentioned in the introduction). 
  * Much room for improving the structure of the paper.

The abstract is well written and gives an idea about the problem statement and the approach to solve the problem. It also outlines the contribution of the approach. However, it is also good to briefly mention the result. The Introduction section did not mention anywhere about the remote patient monitoring system " Bionous PHware".  I am curious to know if there are any prior research in a similar field? The authors did not mention it in the Introduction, and there is no separate "Related Work" section. In the third paragraph of the Introduction, the authors mention "Formal Verification" in the third paragraph but did not explain it before. A brief explanation about Formal Verification would be helpful. The methodology is explained very well in the Introduction. However, in the second last paragraph, it is mentioned " The SPIN model checker found many instances where the workflow did not make appropriate decisions given the state of risk awareness, and there were many times w!
here the system designer made changes to the workflow, believing
the changes to preserve correctness only to have the model checker show otherwise." According to the track, it is also important to explain the negative findings. The authors did not explain the findings of why the system earlier did not make appropriate decisions. --- *added be EGM* this result is **not** a negative result as it shows the value of the model checker in helping the engineer analyze the system.

In section 2, I am curious to know what are the 4 point of scale severity level and how the levels are selected? It is also important to explain why having "secLvl<2`` in figure 1. Is it a threshold? If the methodology and evaluation are shown through a case study, it will be easier for the reader to understand it clearly. The paper did not outline the industrial importance of the research and the contributions of this research need to be highlighted more. 

The paper is missing a clear and detailed description of the methodologies. The contributions of this approach at this stage do not seem promising. The research has much room for significant improvements. 

Minor comment: in the heath --> Health

# Review 2

**SCORE:** -1 (weak reject)

Summary

In this paper, the authors present an application of model checking in the domain of health care.
Requirements concerning patient monitoring are formalised as cognitive work problems (basically an automaton), which is then translated to LTL and used to verify implemented workflows.  Workflows are modelled with BPMN and have to be translated to Promela models that can then be checked against the LTL formulae using SPIN as a model checker.  According to the authors, the primary contribution is the set of LTL properties for the specific cognitive work problem (CWP).

Strengths

The presented scenario is a convincing application of model checking with great potential.  I find it well-suited to both the conference and track.

Weaknesses (and suggestions for improvement)

- I do not understand how the primary contribution can be the specific set of LTL properties for the particular CWP.  More useful/interesting would be the systematic process applied to derive and validate the LTL properties.  The authors state themselves that the paper does NOT touch on the many iterations involved in deriving the final set of LTL properties.  This is disappointing - if I have a similar application what I can reuse from the authors is more how to apply a similar solution strategy (a systematic method) and less the concrete LTL properties.
- The authors do not explain how the manually derived formal models (LTL, Promela) are validated.  How do we know these are correct?  This is a crucial point as the entire formal verification can otherwise be a waste of time.  Are there any ideas in this direction?  How did the authors address this challenge?  How do others do this?
- While there is some mention of related work here and there I’m still missing a dedicated section comparing the authors’ contribution to other related approaches.  How about approaches that accomplish similar goals using a different tool suite and approach?  What are strengths and weaknesses of alternative approaches and technologies?  What are open challenges?  When does the authors’ approach make sense and when not?
- I would have appreciated some basic explanation of Promela syntax - the authors just assume all readers speak Promela.  In general, I feel the sections presenting the concrete models can be shortened to provide space for the underlying development process.
- Why isn’t scalability a problem?  Because the CWP is simple?  Because the properties are simple? Scalability is typically a challenge for model checking so some comments would be helpful here.
- The conclusion section makes it clear that the authors have not yet solved two basic problems:  (1) automating the formalisation, and (2) transforming results back to a representation that domain experts can understand.  These two problems are very typical for formal verification and IMHO are exactly the reason why formal verification is not as successful in practice as it could/should be.  Just mentioning these two points (non-trivial challenges) as “ongoing work” is highly dissatisfying.  Perhaps the authors should postpone a submission until these points have been sufficiently addressed.

# Review 3

**SCORE:** 1 (weak accept)

This paper reports on an interesting and successful industrial experience in using model-checking for tele-monitoring health systems. The approach uses a model cognitive work problems (CWP, essentially a global state machine) for requirements, and a BPMN model for the distributed tele-monitoring system. The paper describes, through an example, the manual conversion of the CWP to LTL properties, and of the BPMN model to Promela. SPIN is used to verify that the properties hold on the workflow model. 

**Strengths**:

  * Interesting and relevant application domain
  * Original mapping of CWP to LTL, with handling of fairness
  * Good discussion of the conversions and of underlying assumptions and design choices
  * Models and results available online

**Points to improve**:

  * A more quantified description of the benefits would strengthen the discussion
  * The relationship between CWP and conventional “observers” should be discussed.
  * Related work and limitations spread out over many sections.

Nice application of model checking to an interesting domain. I have liked this paper in general. There are several opportunities for improvement:

  * Fig. 1 defines the CWP as a state machine. How do we know it captures reality properly? For example, why isn’t there another G transition from, “Pt in appropriate home care” to “Pt expired”, as death could have been caused by issues not monitored by the system?
  * Fig. 2 described the workflow model in BPMN. It is unclear whether the conditions on gates are actually deterministic (and ideally exhaustive). Is this an issue?
  * I was hoping for a more quantitative reporting of the errors/problems detected (e.g., how many of what kind, and was the effort invested useful?). This would be valuable too,
  * I liked the definition and use of “fairness” in this approach (page 5). I see originality in how it was used throughout the example.
  * Does the use of global variables (section IV) prevent the detection of a category of errors what would be visible with the encoding of messages (e.g., race conditions)?
  * In the atomic part of page 7, the first two lines (consumeToken(homeCareFlowTask05In00), consumeToken(homeCareFlowTask05In01)) look more like a AND (both mandatory) than an OR (i.e., only one should be mandatory), unlike the explanation below that piece of code. Please clarify.
  * I have found the mapping from CWP to LTL interesting. In the end however, a CWP model is a global state machine that expresses partial behaviour the system must comply with. There is some literature on “observers” and “monitors” that share much commonality. It would be good to situate CWP in that context. For example, see: Besnard, V., Teodorov, C., Jouault, F., Brun, M., & Dhaussy, P. (2019, September). Verifying and monitoring UML models with observer automata: a transformation-free approach. In 2019 ACM/IEEE 22nd International Conference on Model Driven Engineering Languages and Systems (MODELS) (pp. 161-171). IEEE.
  * While a state machine is used as requirements and workflows as design here, others have used the opposite (state machines model-checked against activity diagrams transformed to LTL). See: M. Sharbaf, B. Zamani and B. T. Ladani, "Towards automatic generation of formal specifications for UML consistency verification," 2015 2nd International Conference on Knowledge-Based Engineering and Innovation (KBEI), 2015, pp. 860-865, doi: 10.1109/KBEI.2015.7436156.

Small points:

  * Abstract: preserves patient safety (I would add “properties” to this sentence; there is only so much the system can do)
  * p3: Business Process Modeling Notation -> Business Process Model and Notation
  * p3: trends exceeds -> trends exceed
  * p4: please enlarge Fig. 2 as it is too small when printed.
  * p5: exist somewhere -> Exists somewhere
  * p5: disjunction … require (add “s”)
  * p5: a existential -> an existential
  * p7: the for -> for
  * p7: first being -> first is … second being -> second is
  * p8: While the End 196 -> Meanwhile, the End 196
  * p8: all input -> all inputs
  * p9: how verify -> how to verify
  * p10: together SPIN (???)
  * p10: being is -> is
 
  * References need some improvements:
  
    * some authors are missing (e.g., [5, 20, 26, 27])
    * capitalization (k. shoroder in [7], Akaike in [14], Bpmn and promela in [26]…)
    * missing venues/journals ([13, 17, 23, 25]

If space is needed, fig. 3 can be shorten substantially; the lines related to states are repeated and not very useful anyway. I suggest removing them.
