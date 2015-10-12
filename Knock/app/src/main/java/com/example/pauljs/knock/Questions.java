package com.example.pauljs.knock;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Created by pauljs on 10/11/2015.
 */
public class Questions implements Serializable{

    private Question initQuestion;
    private ArrayList<Question> questions;

    public Questions() {
        questions = new ArrayList<>();
    }

    //Assumes first question added is first question
    public void add(Question question) {
        if(questions.size() == 0) {
            initQuestion = question;
        }
        questions.add(question);
    }

    public void setInitQuestion(Question initQuestion) {
        this.initQuestion = initQuestion;
    }

    public Question getFirstQuestion() {
        return initQuestion;
    }

    public String getQuestionByKey(String key) {
        for(Question question : questions) {
            if(question.getKey().equals(key)) {
                return question.getQuestion();
            }
        }
        return null;
    }


}
