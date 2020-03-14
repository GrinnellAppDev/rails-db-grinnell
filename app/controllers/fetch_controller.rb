# frozen_string_literal: true

require 'open-uri'
require 'net/http'
require 'json'
class FetchController < ApplicationController
  def fetch
    # raw_cookie = {
    #   Name: 'acceptsCookies',
    #   Value: 'accepts',
    #   Host: 'www.edinburghnews.scotsman.com',
    #   Path: '/',
    #   Expires: 'Fri, 10 Oct 2025 16:53:34 GMT',
    #   Secure: 'No',
    #   HttpOnly: 'No'
    # }
    # cookie = raw_cookie.map { |b| b.collect { |key, val| format('%s=%s', key, val) }.join '; ' }.join '; '
    c = ".AspNet.Cookies=#{attri_params[:token]}; path=/; domain=.itwebapps.grinnell.edu;"
    puts "\n\n\n\n\n"
    attri_params.each { |_x, y| y&.gsub!(/\s+/, '+') }
    puts attri_params[:campusquery]
    data = open("https://itwebapps.grinnell.edu/private/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=&LastName=#{attri_params[:lastName]}&LNameSearch=startswith&FirstName=#{attri_params[:firstName]}&FNameSearch=startswith&email=#{attri_params[:email]}&campusphonenumber=#{attri_params[:campusPhone]}&campusquery=#{attri_params[:campusquery]}&Homequery=#{attri_params[:homeAddress]}&Department=#{attri_params[:facultyDepartment]}&Major=#{attri_params[:major]}&conc=#{attri_params[:concentration]}&SGA=#{attri_params[:sga]}&Hiatus=#{attri_params[:hiatus]}&Gyear=#{attri_params[:studentClass]}\&submit_search=Search&pagenum=#{attri_params[:page]}",
                'Cookie' => c,
                'User-Agent' => 'Mozilla/5.0',
                'Referer' => 'https://login.microsoftonline.com/',
                'Origin' => 'https://login.microsoftonline.com').read

    doc = Nokogiri::HTML(data)
    arr = []
    # return if the cookie is expired
    if doc.at('p:contains("Your request for a directory entry at Grinnell College where")').nil?
      render json: {
        errMessage: 'Expired cookie',
        status: 401
      }
      return
    end
    # get the number of people
    doc_people = doc.at('p:contains("Your request for a directory entry at Grinnell College where")').text.strip
    number_of_people = doc_people.match(/found\s\d+\sentries/).to_s.split(' ')[1]
    # check whether the server think it is too many people to display
    toomany = doc.at('p:contains("large number of records and you must reduce the number of matches by refining your search criteria using the form at the bottom of the page")')
    if toomany.nil? == false
      puts "\n\n\n\n"
      render json: {
        errMessage: 'found too many people, please narrow the range',
        status: 400,
        numberOfPeople: number_of_people
      }
      return
    end

    comp = 'On Campus ViewUsers may not send anonymous mail, mail with altered headers giving erroneous information, or anonymous files.'
    istext = false
    i = 0
    doc.css('td').each_with_index do |element, _index|
      if istext && (element.text.strip != 'New Search')
        if element.attr('colspan').nil?
          if (i % 8).zero?
            arr << [get_picture(element)]
          elsif (i % 8) == 1
            arr[i / 8] << getname(element)
          else
            arr[i / 8] << getother(element)
          end
          i += 1
        elsif element.attr('colspan') == '1'
          arr[(i - 1) / 8] << element.text.strip
        elsif element.attr('colspan') == '2'
          arr[(i - 1) / 8] << getother(element) if element.text.strip != ''
        elsif element.attr('colspan') == '6'
          arr[(i - 1) / 8] << element.text.strip
        end
      elsif istext && (element.text.strip == 'New Search')
        break
      elsif element.text.strip == comp
        istext = true
      end
    end
    page_num = doc.at('span:contains("Pages")')
    page = page_num.nil? ? '1' : page_num.text.strip.split.last
    current_page = page == '1' ? '1' : page_num.text.match(/\(.*\)/).to_s[1]
    arr.map!(&:flatten)

    # convert the arr into a list of person
    users = []
    arr.each do |p|
      a = {
        imgPath: p[0],
        firstName: p[1].split(', ')[1],
        lastName: p[1].split(', ')[0],
        userName: p[2].split('=')[1],
        phone: p[4],
        email: p[5],
        address: p[6],
        box: p[7],
        type: p[8]
      }
      b = {
        type: p[8],
        person: a
      }
      if b[:type] == 'Faculty / Staff'
        a[:title] = p[3]
        b[:type] = 'Faculty'
      else
        a[:major] = p[3]
      end
      if p.length > 9
        b['type'] = 'SGA'
        a['SGAtitle'] = p[9]
        a['SGAphone'] = p[10]
        a['SGAemail'] = p[11]
        a['SGAoffice'] = p[12]
        a['SGAbox'] = p[13]
      end
      if a[:major]&.include?('(20')
        a[:classYear] = a[:major].split(' (')[1][0, 4]
        a[:major] = a[:major].split(' (')[0]
      end
      a['SGAofficeHour'] = p[15] if p.last.include?('Office Hours')
      puts p
      puts "\n\n\n\n\n"
      users << b
    end
    # for each user, go to their info page to retrive their data
    if users.nil?
      render json: {
        errMessage: 'No Such Person',
        status: 402
      }
      return
    end
    # render data
    render json: {
      errMessage: '',
      numberOfPeople: number_of_people.nil? ? users.length : number_of_people.to_i,
      currentPage: current_page.to_i,
      maximumPage: page.to_i,
      status: 200,
      content: users
    }
  end

  def fetch_personal_info
    c = ".AspNet.Cookies=#{personal_info_params[:token]}; path=/; domain=.itwebapps.grinnell.edu;"
    data = open("https://itwebapps.grinnell.edu/private/asp/campusdirectory/GCdisplaydata.asp?SomeKindofNumber=#{personal_info_params[:username]}",
                'Cookie' => c,
                'User-Agent' => 'Mozilla/5.0',
                'Referer' => 'https://login.microsoftonline.com/',
                'Origin' => 'https://login.microsoftonline.com').read
    doc = Nokogiri::HTML(data)
    # check whether it is invalid
    if doc.at('p:contains("Invalid column name")') != nil
      render json: {
        errMessage: 'Invalid username',
        status: 400
      }
      return
    end

    if doc.at('h4:contains("Detailed Information as of")').nil?
      render json: {
        errMessage: 'cookie expired',
        status: 401
      }
      return
    end

    all_td = doc.css('td').map { |x| x.text.strip }
    i = 0
    actual_text = false
    arr = []
    all_td.each do |x|
      if actual_text
        arr << x
      else
        puts x
        actual_text = true if x == 'On-Line Campus Directory '
      end
    end
    arr = arr[4...(arr.length - 3)]
    key_arr = []
    value_arr = []
    arr.each_with_index do |ele, index|
      if index.even?
        key_arr << ele
      else
        value_arr << ele
      end
    end

    person = {}
    key_arr.each_with_index do |x, y|
      if x != ':'
        person[x[0, (x.length - 1)]] = value_arr[y]
      else
        person[key_arr[y - 1][0, (key_arr[y - 1].length - 1)]] += value_arr[y]
      end
    end
    render json: person
  end

  private

  def get_picture(noko)
    if noko.at_css('img').nil?
      nil
    else
      noko.at_css('img').attr('src')
    end
  end

  def getname(noko)
    [noko.text.strip, noko.at_css('a').attr('href')]
  end

  def getother(noko)
    noko.text.strip
  end

  def attri_params
    params.permit(:lastName, :firstName, :email, :campusPhone, :homeAddress, :facultyDepartment, :major, :concentration, :sga, :hiatus, :studentClass, :token, :campusquery, :page)
  end

  def personal_info_params
    params.permit(:username, :token)
  end
end
