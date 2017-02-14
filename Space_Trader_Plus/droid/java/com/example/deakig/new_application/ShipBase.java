package com.example.deakig.new_application;

/**
 * Created by greg on 25/12/15.
 */
public class ShipBase {

    private Integer balloon;
    private Integer reactor;
    private Integer drive;

    public void setBallon(Integer i) {
        balloon=i;        
    }
    public void setReactor(Integer i) {
        reactor=i;
    }
    public void setDrive(Integer i) {
        drive=i;
    }

    public Integer getBalloon() {
        return(balloon);
    }
    public Integer getReactor() {
        return(reactor);
    }
    public Integer getDrive() {
        return(drive);
    }

}
