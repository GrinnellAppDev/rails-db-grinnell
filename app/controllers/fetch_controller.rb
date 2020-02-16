require 'open-uri'
require 'net/http'
class FetchController < ApplicationController
  def fetch
    raw_cookie = {
      Name: 'acceptsCookies',
      Value: 'accepts',
      Host: 'www.edinburghnews.scotsman.com',
      Path: '/',
      Expires: 'Fri, 10 Oct 2025 16:53:34 GMT',
      Secure: 'No',
      HttpOnly: 'No'
    }
    c = ".AspNet.Cookies=#{cookie_value}; path=/; domain=.itwebapps.grinnell.edu; ASPSESSIONIDQUAADBDQ=HLEKMLGDCDLLNKJCJACNFEEF; path=/; domain=.itwebapps.grinnell.edu; ASPSESSIONIDQUBACADR=KLNCBDPBFJFFCDGDDDMBCOPH; path=/; domain=.itwebapps.grinnell.edu; ASPSESSIONIDQUBACADR=BMNCBDPBLKKGHFLPACBBDPDP; path=/; domain=itwebapps.grinnell.edu; Secure; ASPSESSIONIDQUBACBCQ=BGKLCHAAFMPBDENDAJHGNCIM; path=/; domain=.itwebapps.grinnell.edu; ASPSESSIONIDQWCACADR=HAOLHDFBHPPNEHILFBICJNLA; path=/; domain=.itwebapps.grinnell.edu; FedAuth=QVFBQUFOQ01uZDhCRmRFUmpIb0F3RS9DbCtzQkFBQUFjcnVqUGJZbEJVK3g3bWNYTW9hRkZnQUFBQUFDQUFBQUFBQURaZ0FBd0FBQUFCQUFBQUNKeWl1TTNEODNkUVNEYzJ1WmtWdU9BQUFBQUFTQUFBQ2dBQUFBRUFBQUFKb0V3M1dFV3pQb2NZbjhCSUlPc2taQUFnQUFmdHoyUk84L29TOUU0VFhqeGlVWjc1SmZKcTU3bnpTcVNxK2ZXRVkrZXIwNXhHclFMRHVvZkJyMy9YQS9sUE1HNGF4aXFsVWMwb3FvNWphdTJJb016Q2FRVkNPUE5UUENja2dZUTkxT3RQVFhRMGZ6TFY2ejNuRUIxbzRBZ2hSeHRMVGpHcVRKYTAra3M3YzVLL0owSllVV0dmZlV2UlUwNTlZMVNYNVdBQW9Tb0hKTFlhc0swYkVBZGt3ZitGdVVaWDB2eUdVZ05vNnc1TkZLU3ZSV1BvK1BYTzdCZUsvR0RtNnVoYUY0RlRNY0VLZURDTW5mcWxZaXhNcnJvSnBsSG15Ymc3SHk2SzBRRTFFZlZENjVrMFl2a0FpcitOMkxTVXVVdTdDQmdRVHgyMWtqTmRuL0NtbkpzMVhkNlkzL0t3UHN1K1hTanA2TGRsTzVpdGRUbDN6SndXSVA5SmZsa3B2cnErWGYzbmh6blJMVm5ZZUVPM2lJSk9EWVNIMHYzV0IwbzB2ZDFuVE5pY3BCVnd1ekZ6bkhzZ3RrUTc2V2R0QVBrZlVRQXdUS29KUnpNM0RONGY2QUhZa2VIam5NbWJnMCtiQlFZaEJOWHVwZkV0OU5Tb0F2YzdMRkpBRjU3WW1pMDArQ3FTOGN4UXdDSFphNlBhaEgyc09KTkdOSTVDNG0vcDA3L24wSHFrUXY4MTFWY3NVc09DZ3BmaVRhUys3SmZVTFJLVVRpek5xSllvaEE4dTZjRnlSRVZwL3k2U25kZTVUQ1B6Uk1aY1dBMHZjZHFYcVV1Q1NEVVpyZzFUM3Byd0ZUUVptSXlLQXRsU05YVHNHRFlYSmpJdkV5K3BnTExhRmpWS2RqWWNaVzlJb3Y1bFphbGFWSkRjQzEzRUhMVUpWckFCSkw2TDhoU0lDVWMrd1d4dHBDYmEwRnloWlZyZElyMm9OWm1DUmtwdWdrcWJlelVoTXFsQTA5SktpbEhVeVAxVjBsY2dOK1B4RUM4SlJKTkU2UUFzS0NGQUFBQUhMeXZIWUFVNUJ0Zm1iMEpaK3Y4NkljV3VIQzwvQ29va2llPjwvU2VjdXJpdHlDb250ZXh0VG9rZW4; path=/; domain=.itwebapps.grinnell.edu;"
    cookie = raw_cookie.map {|b| b.collect {|key,val| "%s=%s" % [key, val]}.join '; '}.join '; '
    # puts cookie
    data = open('https://itwebapps.grinnell.edu/private/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=&LastName=guo&LNameSearch=startswith&FirstName=&FNameSearch=startswith&email=&campusphonenumber=&campusquery=&Homequery=&Department=&Major=&conc=&SGA=&Hiatus=&Gyear=&submit_search=Search',
      "Cookie" => c,
      "User-Agent" => "Mozilla/5.0",
      "Referer" => "https://login.microsoftonline.com/",
      "Origin" => "https://login.microsoftonline.com").read

    doc = Nokogiri::HTML(data)
    puts doc.title
    tag = {};
    comp = "On Campus ViewUsers may not send anonymous mail, mail with altered headers giving erroneous information, or anonymous files."
    istext = false
    doc.css('td').each_with_index do |element, index|
      if istext && (element.text.strip != "New Search")
        puts "#{index + 1}. #{element.text.strip}"
        tag[index] = element.text.strip
      elsif istext && (element.text.strip == "New Search")
        break
      elsif element.text.strip == comp
        istext = true
      end
    end
    # render data
    render json: {
      hahah: tag
    }
  end
end
