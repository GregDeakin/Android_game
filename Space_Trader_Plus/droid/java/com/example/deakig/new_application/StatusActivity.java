package com.example.deakig.new_application;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.TextView;

/**
 * Created by greg on 26/12/15.
 */
public class StatusActivity  extends AppCompatActivity {

    private ShipMeta shipMeta = new ShipMeta();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_status);
      //  TextView myTextView = (TextView) findViewById(R.id.textView);
        Integer test = shipMeta.getBalloon();
       // myTextView.setText(test.toString());
    }
}
