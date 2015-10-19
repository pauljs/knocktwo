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


  START = 0
  FIRST_RESPONSE = 1
  SECOND_RESPONSE = 2
  if response == "send restart all"
    session.each do |key, value|
      session[key]["counter"] = 0
      message = "Hello! This is Knock, your personal health tracker assistant from your doctor. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
      twiml = Twilio::TwiML::Response.new do |r|
	    r.Message message
	 end
      twiml.text
    end

  else
  if response == "get stuff"
     session[params[:From]]["counter"] -= 1
    message = session[params[:From]].to_s
  elsif sms_count == START
    message = "Hello! This is Knock, your personal health tracker assistant from your doctor. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
  elsif sms_count == FIRST_RESPONSE
    if all_digits? response
      message = "I received your response as\n" + response + "\nPlease confirm if this is correct by answering Y or N for yes or no respectively."
      session[params[:From]]["response"] = response
    else
      message = "Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected a whole number. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
     session[params[:From]]["counter"] -= 1 
    end

  elsif sms_count == SECOND_RESPONSE
    if all_letters? response
      response = response.downcase
      if response == 'y'
        if session[params[:From]]["response"].to_i >= 7
          suggestion = " Glad to see you are getting enough sleep!"
        else
          suggestion = " You should try to get more sleep."
        end
        message = "Your response has been recorded." + suggestion + " If you would like to edit your response, respond with Edit. If you would like to see your results, respond with Stats. Otherwise, I'll let you know when you have another task. Thanks!"
         dict = session[params[:From]]
         if dict == nil
           dict = Hash.new
         end
         cur_time = Time.new
         dict[cur_time.day] = Hash.new
         dict[cur_time.day]["time"] = cur_time
         dict[cur_time.day]["response"] = session[params[:From]]["response"].to_i

      elsif response == 'no'
        message = "Please resend your response to the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
        session[params[:From]]["counter"] -= 2
      else
        message = "Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected Y or N. Please state Y or N for yes or no respectively."
        session[params[:From]]["counter"] -= 1
      end
    else
      message = "Sorry, your response was not in the correct format. I received:\n" + response + "\nbut expected Y or N. Please state Y or N for yes or no respectively."
        session[params[:From]]["counter"] -= 1
    end
  elsif sms_count > SECOND_RESPONSE && all_letters?(response) && response.downcase == "edit"
    message = "Hello! This is Knock, your personal health tracker assistant from your doctor. Please answer the following question in whole numbers.\nHow many total hours of sleep did you get last night? (e.g. 8)"
    session[params[:From]]["counter"] = 0 
  elsif sms_count > SECOND_RESPONSE && all_letters?(response) && response.downcase == "stats"
    temp = session[params[:From]]
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    message = "Statistics:\n"
    num = 0
    temp.each do |key, value|
      if key != "counter"
        time = temp[key]["time"]
        message +=  months[time.day] + ": " + temp[key]["response"] + "\n"
        sum += temp[key]["response"]
        num += 1
      end
      if num != 0
        message += "Avg Hours of Sleep: " + (sum / num) + "\n"
        if (sum / num) >= 7
          message += "Glad to see you are getting enough sleep!"
        else
          message += "You should try to get more sleep."
        end
      end
    end
  else
    message = "You have completed this task. If you would like to edit your response, respond with Edit. If you would like to see your results, respond with Stats. Otherwise, I'll let you know when you have another task. Thanks!"
  end
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message
  end
  session[params[:From]]["counter"] += 1
  twiml.text
  end
end
