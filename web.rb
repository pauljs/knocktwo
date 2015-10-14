require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
#evaluate by asking reasons for delayed responses
enable :sessions

#get '/' do
#  'Hello World! Currently running version ' + Twilio::VERSION + ' of the twilio-ruby library.'
#end

def all_letters? str
  str[/[a-zA-z]+/] == str
end

def all_digits? str
  str[/[0-9]+/] == str
end


get '/sms-quickstart' do
  response = params[:Body]
  #session["counter"] = -1
  session[params[:From]] ||= Hash.new
  session[params[:From]]["counter"] ||= 0
  sms_count = session[params[:From]]["counter"]

  if response != "get stuff"
    message = session[params[:From]].to_s
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message message
    end
    twiml.text
    return
  end

  START = 0
  FIRST_RESPONSE = 1
  SECOND_RESPONSE = 2
  if sms_count == START
    message = "Hello! This is Knock, your personal health tracker assistant from your doctor. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
  elsif sms_count == FIRST_RESPONSE
    if all_digits? response
      message = "I received your response as\n" + response + "\nPlease confirm if this is correct by answering Yes or No."
      session[params[:From]]["response"] = response
    else
      message = "Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected a whole number. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
      session["counter"] -= 1 
    end

  elsif sms_count == SECOND_RESPONSE
    if all_letters? response
      response = response.downcase
      if response == 'yes'
        if session["response"].to_i >= 7
          suggestion = "Glad to see you are sleeping enough!"
        else
          suggestion = "You should try to get more sleep."
        end
        message = "Your response has been recorded." + suggestion + " If you would like to edit your response, respond with Edit. Thanks!"
         dict = session[params[:From]]
         if dict == nil
           dict = Hash.new
         end
         cur_time = Time.new
         dict[cur_time.hour] = session[params[:From]]["response"]

      elsif response == 'no'
        message = "Please resend your response to the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
        session["counter"] -= 2
      else
        message = "Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected Yes or No. Please state Yes or No."
        session["counter"] -= 1
      end
    else
      message = "Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected Yes or No. Please state Yes or No."
        session["counter"] -= 1
    end
  elsif sms_count > SECOND_RESPONSE && response.downcase == "edit"
    message = "Hello! This is Knock, your personal health tracker assistant from your doctor. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
    session["counter"] = 0
  else
    message = "You have completed this task. If you would like to edit your response, respond with Edit; otherwise, I'll let you know when you have another task!"
  end
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message
  end
  session["counter"] += 1
  twiml.text
end
