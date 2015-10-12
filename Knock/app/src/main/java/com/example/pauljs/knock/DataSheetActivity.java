package com.example.pauljs.knock;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by pauljs on 9/28/2015.
 */
public class DataSheetActivity extends Activity {

    private int currentQuestionId;
    private Question currentQuestion;
    private TextView questionTV;
    private Button nextBtn;
    private EditText responseET;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.data_sheet);
        currentQuestionId = 1;
        Questions questions = (Questions) getIntent().getSerializableExtra("questions");
        currentQuestion = questions.getFirstQuestion();
        questionTV = (TextView) findViewById(R.id.textView);
        responseET = (EditText) findViewById(R.id.editText);
        InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.showSoftInput(responseET, InputMethodManager.SHOW_IMPLICIT);
        imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_IMPLICIT_ONLY);
        questionTV.setText(currentQuestion.getQuestion());
        nextBtn = (Button) findViewById(R.id.button);
    }

    public void nextBtnOnClick(View v) {
        getNextQuestion(responseET.getText().toString());
    }

    private void getNextQuestion(String response) {
        switch(currentQuestionId) {
            case 1: {
                if(isAllDigits(response)) {
                    questionTV.setText("I received your response as\n" + response + "\nPlease confirm if this is correct by answering Yes or No.");
                    responseET.setInputType(InputType.TYPE_CLASS_TEXT);
                } else {
                    questionTV.setText("Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected a whole number. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)");
                    currentQuestionId -= 1;
                }
                break;
            }
            case 2: {
                if(isAllLetters(response)) {
                    response = response.toLowerCase();
                    if(response.equals("yes")) {
                        Toast.makeText(DataSheetActivity.this, "Task complete!", Toast.LENGTH_LONG).show();
                        finish();
                    } else if(response.equals("no")) {
                        questionTV.setText("Please resend your response to the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)");
                        responseET.setInputType(InputType.TYPE_CLASS_NUMBER);
                        currentQuestionId -= 2;
                    } else {
                        questionTV.setText("Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected Yes or No. Please state Yes or No.");
                        currentQuestionId -= 1;
                    }
                } else {
                    questionTV.setText("Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected Yes or No. Please state Yes or No.");
                    currentQuestionId -= 1;
                }
                break;
            }
        }
        currentQuestionId += 1;
        responseET.setText("");
    }

    private boolean isAllLetters(String str) {
        return str.matches("[a-zA-Z]+");
    }

    private boolean isAllDigits(String str) {
        return str.matches("[0-9]+");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
