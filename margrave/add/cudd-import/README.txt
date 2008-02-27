
  INSTALLATION

- Install CUDD

- Edit Makefile
  edit the CUDIR line of the Makefile to contain the path to the
  cudd directory on your local machine (this is the directory with
  subdirs cudd, util, st, etc).

- Run Makefile
  run "make" in the directory containing the makefile
  (that should be this directory).

- Now you may use DrScheme to run Margrave (see webpage for more on this)


Make sure you do not open DrScheme until after running the above steps
(The PLT Foreign Interface seems to only be able to find functions
 that were compiled before the time of starting DrScheme.)

-------------------------------------------------------------------

What follows are implementationial details that you do not need to
read to use Margrave.

-------------------------------------------------------------------

Usage

  - At the top of your scheme file, include (load "xacml-base.ss")

  - All CUDD operations require an instance of a "decision diagram
    manager" as an argument.  You should use the same manager for your
    entire session.  You create a manager with (make-dd-manager).
 
  - The file xacml-test.ss shows a sample of using the package.  A
    list of available operations is included below.

Potential Problems

  - memory management: The current package does not automatically do
    garbage collection (cudd uses reference counting).  I an working
    on enabling auto-gc through MzScheme.  Ignore GC for now.  If
    memory usage becomes a problem, tell me.

  - missing operations on ADDs: If you need an operation that isn't
    here, tell me and I will extend the package.

---------------------------------------------------------------------

Types used 

  - manager : a data structure that enables ADD operations.  Details
    are irrelevant.

  - XADD : An ADD with the four XACML terminals (permit, deny, na, ec).

  - 0-1-ADD : An ADD with 0 and 1 as terminals (a BDD that looks like
    an ADD).  Used for purely logical manipulation of ADDs.  At
    present, there is no way to convert from an XADD to a 0-1-ADD.  I
    can create such functions later if necessary.
 
  - CADD : An ADD with the nine change analysis terminals
    (permit-permit, permit-deny, etc)

  - ADD : a 0-1-ADD, XADD, or CADD.

  - ADD_CONST : constants for terminal values in our ADDs. Valid values are 
      for XADDs : PERMIT_VAL, DENY_VAL, NA_VAL, EC_VAL 
      for CADDs : PP_VAL, PD_VAL, PN_VAL, PE_VAL,
                  DP_VAL, DD_VAL, DN_VAL, DE_VAL,
                  NP_VAL, ND_VAL, NN_VAL, NE_VAL,
                  EP_VAL, ED_VAL, EN_VAL, EE_VAL,

Available Operations (Note that the package currently does not check
whether the right variant of ADD is passed to an operation)

  - make-dd-manager : -> manager
    initializes a new manager.

  - xacml-permit : manager -> XADD
    returns the XADD for the permit constant

  - xacml-deny : manager -> XADD
    returns the XADD for the deny constant

  - xacml-na : manager -> XADD
    returns the XADD for the not-applicable constant

  - xacml-ec : manager -> XADD
    returns the XADD for the excluded-by-constraint constant

  - xacml-new-var : manager -> 0-1-ADD
    returns 0-1-ADD for a new variable.  The order in which you create
    vars determines the variable ordering in the ADD.  Note that the
    package will not associate names with variables -- you need to do
    that in your scheme code.

  - xacml-and : 0-1-ADD 0-1-ADD manager -> 0-1-ADD
    Logical and on 0-1-ADDs

  - xacml-or : 0-1-ADD 0-1-ADD manager -> 0-1-ADD
    Logical or on 0-1-ADDs

  - xacml-not : 0-1-ADD manager -> 0-1-ADD
    Logical negation of 0-1-ADD

  - xacml-augment-rule : 0-1-ADD XADD manager -> XADD
    The first argument is a logical expression on variables forming
    conditions on a rule.  The second argument is an existing rule
    (could be permit/deny/na in the simplest case).  Returns an XADD
    for the rule augmented with the given conditions.

  - combine-permit-override : XADD XADD manager -> XADD
    Combines two XADDs into a policy using permit-override.  The first
    XADD will override the second if no permit occurs.

  - combine-deny-override : XADD XADD manager -> XADD
    Combines two XADDs into a policy using deny-override.  The first
    XADD will override the second if no deny occurs.

  - combine-first-applicable : XADD XADD manager -> XADD
    Combines two XADDs into a policy using first-applicable.  The first
    XADD applies before the second.

  - xacml-print : (XADD or 0-1ADD) manager file-name -> true
    prints a condensed truth table showing the contents of an ADD.
    The columns follow the order of the variables from left to right.
    In a column, 0 means false, 1 means true, and - means that the
    value of the variable is irrelevant (either value satisfies the
    row).  The output is in the far right column.  0 reflects logical
    false, 1 reflects logical true and XACML constants are as they
    appear. 

    Note that this function uses a temporary intermediate file whose
    name is file-name
    
  - add-false : manager -> 0-1ADD
    returns the ADD for logical false

  - add-true : manager -> 0-1ADD
    returns the ADD for logical true

  - cudd-add-constrain : ADD 0-1ADD manager -> ADD
    restricts ADD to the condition given in the 0-1ADD

  - restrict-to : ADD ADD_CONST manager -> 0-1ADD
    returns 0-1ADD where cases mapping to CONST map to 1 and all
    others to 0

  - restrict-to-permit : XADD manager -> 0-1ADD
    returns 0-1ADD where permit cases map to 1 and all others to 0

  - restrict-to-deny : XADD manager -> 0-1ADD
    returns 0-1ADD where deny cases map to 1 and all others to 0

  - xacml-change-merge : XADD XADD manager -> CADD
    produces CADD showing merged results of given policies in order

  - xacml-change-print : CADD mgr -> void
    like-xacml-print, but prints CADDs instead of ADDs    

  - xacml-change-only-print : CADD mgr -> void
    like-xacml-change-print, but prints only change minterms from CADD

  - xadd-assume : XADD 0-1ADD manager -> XADD
    restricts XADD to the condition given in the 0-1ADD, sending cases
    that don't match condition to EC

  - always-false-vars : 0-1ADD manager -> list[bool]
    returns list of same size (and order) of number of vars in which
    true indicates that the corresponding var is always false in the ADD
    and false indicates otherwise

  - always-true-vars : 0-1ADD manager -> list[bool]
    returns list of same size (and order) of number of vars in which
    true indicates that the corresponding var is always true in the ADD
    and false indicates otherwise

  - always-dc-vars : ADD manager -> list[bool]
    returns list of same size (and order) of number of vars in which
    true indicates that the corresponding var is always dont-care in the ADD
    and false indicates otherwise

  - add-equal? : ADD ADD -> boolean
    determines whether two ADDs represent the same function

  - xadd-na-to-deny : XADD mgr -> XADD
    redirects all paths to NA terminal in XADD to DENY terminal

  - xacml-stats : ADD mgr -> void
    prints number of nodes in ADD and memory used by manager