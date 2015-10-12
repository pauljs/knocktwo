package com.example.pauljs.knock;

import java.io.Serializable;
import java.util.HashMap;

/**
 * Created by pauljs on 10/11/2015.
 */
public class Question implements Serializable {

    private String key;
    private HashMap<String, String> jsonMap;

    public Question(HashMap<String, String> jsonMap) {
        this.key = jsonMap.get("key");
        this.jsonMap = jsonMap;
    }

    public String getQuestion() {
        return jsonMap.get("say_text");
    }

    public String getKey() {
        return key;
    }
}
