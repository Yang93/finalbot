require 'sinatra'
require "sinatra/reloader" if development?

require "twilio-ruby"

configure :development do
  require 'dotenv'
  Dotenv.load
end

get "/" do
	404
end

enable :sessions


@client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]


get "/sms/incoming" do
  session["last_intent"] ||= nil

  session["counter"] ||= 1
  count = session["counter"]

  sender = params[:From] || ""
  body = params[:Body] || ""
  body = body.downcase.strip

  message = ""
  media = nil

# Decide whether to send lunch menu or dinner menu based on current time
  time = Time.new
  current_time = time.hour.to_i

  meal_type = "none"
  if current_time >= 14 && current_time <= 18
    meal_type = "dinner"
  elsif current_time >= 0 && current_time <14
    meal_type = "lunch"
  end

# Main conversation starts here
GREETINGS = ["Hi","Yo", "Hey","Hello"]

if body.include?("who are") || body.include?("what can")
  message = "I am a bot that can help you order meals. Type \"menu\" to check out all the delicious meal options!"
elsif body.include?("hi") || body.include?("hello") || body.include?("hey")
  message = GREETINGS.sample + "!" + "I'm your personal meal order helper. Type \"menu\" if you would like to make an order now."
elsif body.include?("menu")
  if meal_type == "none"
    message = "Sorry, the ordering service is not available now. You can make lunch orders between 12:00am-14:00pm and dinner orders between 14:00pm-18:00pm."
  else
    message = "Here is today's #{meal_type} menu: 1. Fried Chicken Bento($8), Rosetea Cafe 2. Stew Beef on Rice($7), Orient Express 3. Shrimp Curry($10), Sichuan Gourmet. Which one would you like to choose? "
  end
elsif body.include?("1")
  message = "Rosetea Cafe will deliver to Cyrt Hall at 11:30am and Library at 12:00pm, please type in your preferred pick-up location and quantity:"
elsif body.include?("2")
  mesage = "Orient Express will deliver to Cyrt Hall at 11:30am and Library at 12:00pm, please type in your preferred pick-up location and quantity:"
elsif body.include?("3")
  message = "Sichuan Gourmet will deliver to Cyrt Hall at 11:30am and Library at 12:00pm, please type in your preferred pick-up location and quantity:"
elsif body.include?("cyrt")
  location = "Cyrt Hall"
  time = "11:30am"
  message = "Your order have been successfully made!" + " Please remember to pick up your meal at "+ location + " at " + time + "."
elsif body.include?("library")
  location = "Library"
  time = "12:00pm"
  message = "Your order have been successfully made!" + " Please remember to pick up your meal at "+ location + " at " + time + "."
elsif body.include?("cancel") or body.include?("change")
  message = "Are you sure you want to cancel your current order? Type \"cancel\" to confirm or \"quit\""
elsif body.include?("thanks") || body.include?("thank you")
  message = "You are very welcome! I'm Glad to help!"
else
  puts "Sorry, can you say it one more time? I didn't get it. "
end


  twiml = Twilio::TwiML::MessagingResponse.new do |r|
    r.message do |m|
      m.body( message)
      unless media.nil?
        m.media(media)
      end
   end
  end

  content_type 'text/xml'
  twiml.to_s

end
