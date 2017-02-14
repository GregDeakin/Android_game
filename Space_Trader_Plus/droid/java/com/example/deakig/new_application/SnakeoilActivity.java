package com.example.deakig.new_application;

import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;

public class SnakeoilActivity extends AppCompatActivity  {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_snakeoil);
        SeekBar mySeekBar = (SeekBar) findViewById(R.id.seekBar);
        mySeekBar.setOnSeekBarChangeListener(new OnSeekBarChangeListener() {
       @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
            // TODO Auto-generated method stub
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
            // TODO Auto-generated method stub
        }

        @Override
        public void onProgressChanged(SeekBar seekBar, int progress,boolean fromUser) {
            // TODO Auto-generated method stub
            TextView myTextView = (TextView) findViewById(R.id.textView);
            myTextView.setText("Hello W");
           // t1.setTextSize(progress);
           // Toast.makeText(getApplicationContext(), String.valueOf(progress),Toast.LENGTH_LONG).show();

        }
    });

    }
   /* private OnSeekBarChangeListener customSeekBarListener =
            new SeekBar.OnSeekBarChangeListener () {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    //do something here
                }
            }*/

}

