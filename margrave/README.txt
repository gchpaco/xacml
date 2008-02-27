
Warning: This program is distributed as a prototype for use in
research and WITHOUT ANY WARRANTY, even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. Margrave should
NOT be used to verify policies for applications.

For documentation, go to the website
http://www.cs.brown.edu/research/plt/software/margrave.

This is the second release of Margrave: Margrave 02-01 (first release
of version 2).  Margrave is an XACML policy and change-impact analysis
tool that runs on PLT Scheme 299.200.

Please email bugs to mtschant 'at' cs.brown.edu.  Also feel free to
email feature requests.  Our research is guided by user needs so there
is a good chance that we will implement it.  We thank you for your
interest.

If you are planing to use Margrave as an end user, you should follow
the directions for use at the above website.  The following gives a
brief overview for people who would like to know how the code is
organized.  Other then the examples directory, end users need not look
at any of them.  (Although analysis/margrave.scm might also be of
interest to end users.)

The directories include:

analysis -- Where the source code for Margrave proper exists.  Use a
PLT Scheme interpreter, MzScheme or DrScheme (see www.plt-scheme.org),
to run after following the installation steps found online.  DrScheme
is recommended.

add -- The implementation of ADDs (also called MTBDDs).  Ideally this
should be a general implementation, but right now it is an
implementation that is only suitable for use in Margrave.  Within this
directory exists the CUDD import written in C.

xacml - Code for the parsing and representation of XACML policies.

lib - general functions used through out the code base.

examples - Contains the code (the Margrave queries and XACML policies)
for the examples found online.