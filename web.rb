require 'rubygems'
require 'twilio-ruby'
require 'sinatra'

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
  session["counter"] ||= 0
  sms_count = session["counter"]
  START = 0
  FIRST_RESPONSE = 1
  SECOND_RESPONSE = 2
  if sms_count == START
    message = "Hello! This is Knock, your personal health tracker assistant from your doctor. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
  elsif sms_count == FIRST_RESPONSE
    if all_digits? response
      message = "I received your response as\n" + response + "\nPlease confirm if this is correct by answering Yes or No."
    else
      message = "Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected a whole number. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
      session["counter"] -= 1 
    end

  elsif sms_count == SECOND_RESPONSE
    if all_letters? response
      response = response.downcase
      if response == 'yes'
        message = "Your response has been recorded. If you would like to edit your response, respond with Edit.  Thanks!"
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
