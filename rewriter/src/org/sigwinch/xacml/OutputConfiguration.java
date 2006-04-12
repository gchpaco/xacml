package org.sigwinch.xacml;

public class OutputConfiguration {
    double slop;
    boolean permit, deny, error;
    public OutputConfiguration (double s, boolean p, boolean d, boolean e) {
        slop = s; permit = p; deny = d; error = e;
    }
    public OutputConfiguration() {
        slop = 2.0;
        permit = false;
        deny = false;
        error = false;
    }
    public boolean isDeny() {
        return deny;
    }
    public boolean isError() {
        return error;
    }
    public boolean isPermit() {
        return permit;
    }
    public double getSlop() {
        return slop;
    }
    public void setDeny(boolean deny) {
        this.deny = deny;
    }
    public void setError(boolean error) {
        this.error = error;
    }
    public void setPermit(boolean permit) {
        this.permit = permit;
    }
    public void setSlop(double slop) {
        this.slop = slop;
    }
}
