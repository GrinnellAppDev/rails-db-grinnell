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
    c = '.AspNet.Cookies=XBlvDMH0MIFV_93RM5ifieOthWG9okcSItqYs-XQ-_3xOwycaJb67XE_rLujKHZHwiR97OuCuhDp6EHYEwJmW15EZ2he3DoTcyJNmIuvcfCG29HKmYlvvnWmNGYrKN62S0eO37yODt52v7Wuhd-JQSJB4KQ_XlZnG8zV1FbAys6Ce7fe-JbsJJm5FhN5VNOhJva0EhdzyurMOona-qPZVDHJXfiY4dJifANFx7JRLrnVquVBoSeKPvrwFxsgdUaCGR2OIH-vvLdidW7RA7KUsPy0asjzNs3_dRyBP8xl5wPfk7o_MV5F_cquTXfklEWfN2Ss3hYLaJqFn6KpRUVK-voAUIU9xfa1Qvii0AJBUSh8FObn6OzcvFyM_EgAnNW2M8Srqky_0pgP5TVzIU05RcYfSt_XEjVfVNi3gpPT0kXpLOxvVW5tlYWGBnn1wQJQkVZZG_Cs86CgMWiTGyhveUUiTPbKwV1y18UnwzBXmnMXGFNXebD_qExPiQ_Q4zSLGVcdSUK5KNoPCol2uNX9CWCly6K_q7xFeanSDzD_Ul8-jHuzYXFgvLoTN-fhbHIuNcQ4RVbStmpdfV7TbncdCRj_8z6aUY8hWwtJttMOjAHI-0-3xe7V5XboXZMMyIg5QjsSRMisafNNAf9oKuQ3hUI2BidQNnx8-q88X97K-7FSEOd726rSbXXsBV7_Sht-_pjDDSpqcLJc2ejLnMbyLBIafhlIltrZvi_RWQdG8wAuTw2_nT1zEPSD70wo14Pm2nzU_c_F4RUWPuYBM1PX1YFh0rI3Sf_pAHhcNMgMnXCg9Tckl6SsKn6kwoAlFQ6OfmJmlcywD1bv2vMVpPAoSI-KWs1F9BGxBcEBf7uAExkXJnaOUHp2bWTi94AyidwwGCDKDyczqOAD1f_ckqD1DAg9GYmDC7VoB4UOzfCHVK2MsLR2C6_6AVZNuqKUR0jhE1oGI5nWnpKLZ5OQsKVWE2G3LMFCNUj_KIWPStjXIJ-YiDtgBRXhBtPSs-rf_rNHhZBW6P1Ogt4bUAgIh6izjHcNmarM_5To3ZoDBEn8c3GzZPdfTzTyvYSQJwWN6D-9W4SELBhc8-XrTRjMsZ6kI7MiBZUemJOLtFrbjRh0q58XiKkWMg1K4FYa-vJDYlMkyX1-CYm4G3xJODWWE0y8ZaZ30Bkn0k1g_eyTTG33biEjiqOXs2CmtlnuSNli_niBoDWZmPV09vtVBhlKL2a0MQvmyo3I3ryDii40sqK0Oos75NLyvI3BAotPotJhloEHFAPeb7cPg4RbM1vNQTpZwx1OQsQcfsZN934uZLfzC-5HvDSl0Lscm8_Qk08xW4nhhCyhWdDJ3FbavluxcBgmpAHwRkI02nYUeNZFBTed_fIM6Idw0B-IPa0OKMY_eQ1UGlfUrljjtYO7jaXDo_1cimsNzSvp4rB9k91gpL-6EwM; path=/; domain=.itwebapps.grinnell.edu;'

    data = open("https://itwebapps.grinnell.edu/private/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=&LastName=#{attri_params[:lastName]}&LNameSearch=startswith&FirstName=#{attri_params[:firstName]}&FNameSearch=startswith&email=#{attri_params[:email]}&campusphonenumber=#{attri_params[:campusPhone]}&campusquery=&Homequery=&Department=#{attri_params[:facultyDepartment]}&Major=#{attri_params[:major]}&conc=#{attri_params[:concentration]}&SGA=#{attri_params[:sga]}&Hiatus=#{attri_params[:hiatus]}&Gyear=#{attri_params[:studentClass]}\&submit_search=Search",
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
    # puts doc.at('span:contains("Pages")').text.strip
    arr.map!(&:flatten)

    # return error if the person doesn't exist
    if arr.nil?
      render json: {
        errMessage: 'person not found',
        errCode: 500
      }
    end
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
    # render data
    render json: {
      errMessage: '',
      status: 200,
      content: users
    }
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
    params.permit(:lastName, :firstName, :email, :campusPhone, :homeAddress, :facultyDepartment, :major, :concentration, :sga, :hiatus, :studentClass)
  end
end
