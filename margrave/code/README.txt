
Warning: This program is distributed as a prototype for use in
research and WITHOUT ANY WARRANTY, even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. Margrave should
NOT be used to verify policies for applications.

The file Margrave.scm will load all the files you need to use
Margrave.  If you plan to use Margrave as an end user, you should only
need functions in this file.  More documentation can be found at
http://www.cs.brown.edu/research/plt/software/margrave.

A problem arises from Margrave calling out to code written in C: The
check syntax command of DrScheme will not work on the code of Margrave
or code that uses Margrave.

Please email any other bugs to mtschant 'at' cs.brown.edu.

Information for people who would like to know implementation details
follow.

For parsing and conversion: 
- xacml-to-ast.scm: parses an XACML policy file into an abstract 
  syntax tree (AST).  
- ast.scm: holds the datastructs that represents an AST.  
- ast-to-add.scm: converts an AST into the ADD representation 
  that is used in asking queries.  
Thus, you can see that a policy goes through three representation: 
the actual XACML file, an AST, and an ADD.

For asking queries:
- Margrave.scm: holds the user level queries.
- add.scm: stores the scheme-level internal of an ADD 
  (also used by ast-to-add.scm)
- tracker.scm: helps add.scm map CUDD nodes to attribute value pairs.
- AccessControl/import.scm: acts as a bridge between the Scheme code 
  of add.scm and the C code.
- AccessControl/import.c: provides imported Scheme functions to 
  interact with CUDD.
