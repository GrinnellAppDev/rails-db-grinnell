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
    c = '.AspNet.Cookies=kK-lB278P_jUWKdeghTuRIXdGaAR7EKN6H7Jp1GM3gluhTG1muq_B6yqrAU8xesnq7uhKS9GDJsZYnEXwTSnOf2ZgNggcXIF-YHuuMmln-fTjVyvVpSSkEYEwHfu32Li_wnJUMtGVmBcMUxi6gPIl13LhGpDamYNwLVMC8Hj2v5sV6q8IHq8R0i2UBTbHc9IqVwyFJmBrlY5Pz6unUz4qiePj7zGgCNVzpZNt4mQdwQ3wHPg0LHNxsMyKx4yij2UoAkZLdT9v4EOfQ97T9W6Sz9KEno9qY11PDcRau3kNZWY8ooy33Qga7jwDPk901kVYkLylk9XFuwmZNTh_AXi86ityIYpuqavW1Q0R4ziMoBVptPEYxFFf3g1vdPpVzdaKt_ngS8BapHHlObT7fgVYAFAbnd3e8YDY4MWdr61jHsncfZkeeOAoKNWeejAEhZlL_vI9fx4uju7Rx70R1Ib0iaJM6ShK3cx-n8TX9VAvxnQTK5frYgbqG3-TZr3irtnYgz4VE54f--HaRE0npg3oIVC4obLX6aAxIrwz4JkYUS9KIPfmiEV3HWBN0GpaQzFpDBGPCOrTw6bhpbzBK5UBFfCgg11viCF6bkBMy1wBfNP3CZemc0GSxBT2M3eMTHLDGzoJKyiQq9AhxmNWOmq11oXACaCYwt-oyhkRrG7y7TnAHczwHQl6kz0-HXycFgI3DkbwO8Lnl892PF3ia2F7Al-H8QuLhBFKDkRkfV20X-1deLBc_sH6NpLma6BXwIMOqbREoOn8piqE0QFYE4J_dwRGKPsT47ieW8F13vwKSXODfKJgI9rjHz9Wx8JWrw7ljMA5YlT3XznWu6mSmTNK2dNIhTJgsbXjTrUVI7btK2Q7m9U5RdomSbRgLLeCzFSK9OilhswdudVkBNyhuiQktwmzND8JRoeJBQ5e9fovCFLLy_zMf0SQsX0q7qZDOwr5T2QFD0Y9B2Eg4eyYWeF2nfXvEJWWZD-uhUKHGJGc57CxQEM1Vyt8tLhGLlD1_VCcj659t7iG87Fdfhx7tprb9hQmhsRFgZSK2fwR2Trbdxo0PmgZ7e3AJ1IjqYQXI2FH81ObEnxJno29G17sgf04fo-TGE9EiCImp_RcHbnLwX0KojWsZ_aE2tXRqM6bAd45PstfXx4VFKgJBu8B7HqvVJeagX1D2U5ren92aAS3Gqy2NSjM_movNkDP1KnPSc4aW2lPbrIHgr1WCn7VN0SqzmI8JKfmS2wI7imSXUYr-k1zyZNspw4X3pXv869nzuDPCRlCm2VMkYtLgm8HzL23IiRYoaxXFitc_8gQkPWJcsUeJIylZrx3jpLSOwl-mdnzZYk7ho9RYDVdA00hQxLBdH0prC6xaVnNo3L6_yuPWcusCPzBx-NHfWrGYsCwVfJCAnwN4NTlgu56RV7tPcHwYZH8n-D4zqEabvcQprBiKA; path=/; domain=.itwebapps.grinnell.edu;'

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
    # render data
    render json: {
      errMessage: '',
      maximumPage: page,
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
