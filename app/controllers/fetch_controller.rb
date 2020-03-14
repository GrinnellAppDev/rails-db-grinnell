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

    attri_params.each { |_x, y| y&.gsub!(/\s+/, '+') }
    puts attri_params[:campusquery]
    data = open("https://itwebapps.grinnell.edu/private/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=&LastName=#{attri_params[:lastName]}&LNameSearch=startswith&FirstName=#{attri_params[:firstName]}&FNameSearch=startswith&email=#{attri_params[:email]}&campusphonenumber=#{attri_params[:campusPhone]}&campusquery=#{attri_params[:campusquery]}&Homequery=#{attri_params[:homeAddress]}&Department=#{attri_params[:facultyDepartment]}&Major=#{attri_params[:major]}&conc=#{attri_params[:concentration]}&SGA=#{attri_params[:sga]}&Hiatus=#{attri_params[:hiatus]}&Gyear=#{attri_params[:studentClass]}\&submit_search=Search",
                'Cookie' => c,
                'User-Agent' => 'Mozilla/5.0',
                'Referer' => 'https://login.microsoftonline.com/',
                'Origin' => 'https://login.microsoftonline.com').read

    doc = Nokogiri::HTML(data)
    arr = []
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
    page = doc.at('span:contains("Pages")')
    page = page.nil? ? '1' : page.text.strip.split.last
    puts page
    puts "\n\n\n\n\n\n\n\n"
    arr.map!(&:flatten)

    # convert the arr into a list of person
    users = []
    arr.each do |p|
      a = {
        imgPath: p[0],
        firstName: p[1].split(', ')[1],
        lastName: p[1].split(', ')[0],
        userName: p[2].split('=')[1],
        major: p[3],
        phone: p[4],
        email: p[5],
        address: p[6],
        box: p[7],
        type: p[8]
      }
      if p.length > 9
        a['type'] = 'SGA'
        a['SGAtitle'] = p[9]
        a['SGAphone'] = p[10]
        a['SGAemail'] = p[11]
        a['SGAoffice'] = p[12]
        a['SGAbox'] = p[13]
      end
      if a[:major].include?('(20')
        a[:classYear] = a[:major].split(' (')[1][0, 4]
        a[:major] = a[:major].split(' (')[0]
      end
      a['SGAofficeHour'] = p[14] if p.last.include?('Office Hours')
      users << a
    end

    # for each user, go to their info page to retrive their data

    # render data
    render json: {
      errMessage: '',
      maximumPage: page,
      status: 200,
      content: users
    }
  end

  private

  def fetch_personal_info(_coockie, _somekindofnumber)
    1
  end

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
    params.permit(:lastName, :firstName, :email, :campusPhone, :homeAddress, :facultyDepartment, :major, :concentration, :sga, :hiatus, :studentClass, :token)
  end
end
