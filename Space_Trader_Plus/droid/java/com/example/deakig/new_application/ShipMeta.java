package com.example.deakig.new_application;

/**
 * Created by greg on 25/12/15.
 */

public class ShipMeta extends ShipBase {

    private Integer balloonSize;
    private Integer currentBalloonSize;
    private ShipComponentCrewQuarters CrewQuarters = new ShipComponentCrewQuarters();

    public ShipMeta(){
        initShipMeta();

    }

    private void initShipMeta(){
        setBallon(5);
        setDrive(5);
        setReactor(5);

        balloonSize = (int)Math.floor(getBalloon() * getDrive());
       // currentBalloonSize=getCurrentBalloonSize();
    }

    private Integer getCurrentBalloonSize(){
        return(balloonSize-CrewQuarters.getBalloonSize());

    }

}
