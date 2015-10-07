require 'rubygems'
require 'twilio-ruby'
require 'sinatra'

enable :sessions

#get '/' do
#  'Hello World! Currently running version ' + Twilio::VERSION + ' of the twilio-ruby library.'
#end


get '/sms-quickstart' do
  response = params[:Body]
  #session["counter"] = 0
  session["counter"] ||= 0
  sms_count = session["counter"]
  START = 0
  FIRST_RESPONSE = 1
  SECOND_RESPONSE = 2
  if sms_count == START
    message = "Hello! This is Knock, your personal health tracker assistant from your doctor. Please answer the following question by providing your answer in whole numbers./n How many total hours of sleep did you get last night?"
  elsif sms_count == FIRST_RESPONSE
    if response.is_a? Integer
      message = "I received your response as\n" + response + "\n Please confirm if this is correct by answering Yes or No."
    else
      message = "Sorry, your response was not in the correct format. I received:/n" + response + "/n but expected a whole number. Please answer the following question by providing your answer in whole numbers./n How many total hours of sleep did you get last night?"
      session["counter"] -= 1 
    end

  elsif sms_count == SECOND_RESPONSE
    if response.is_a? String
      response = response.downcase
      if response == 'yes'
        message = "Your response has been recorded. Thanks!"
      elsif response == 'no'
        message = "Please resend your response to the following question by providing your answer in whole numbers./n How many total hours of sleep did you get last night?"
        session["counter"] -= 2
      else
        message = "Sorry, your response was not in the correct format. I received:/n" + response + "/n but expected Yes or No. Please state Yes or No."
        session["counter"] -= 1
      end
    else
      message = "Sorry, your response was not in the correct format. I received:/n" + response + "/n but expected Yes or No. Please state Yes or No."
        session["counter"] -= 1
    end

  else
    message = "You have completed this task. I'll let you know when you have another!"
  end
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message
  end
  session["counter"] += 1
  twiml.text
end
