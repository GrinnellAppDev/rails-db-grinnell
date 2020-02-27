# frozen_string_literal: true

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
    c = '.AspNet.Cookies=Zk_1Bc4fu5ASjVhH8dLytkbjuZgaza-X8FH5frC11gXpoEqWvO3xt6maV4Gsz5gaqACphzj3RQitcVzYrlhDPYZto5BqKMho4r0M0jvoBcPllUFG4d4RY7oZXJNa4B7q0RSYVFN2UtExsbsit4jQgiA2A0vhMaanVEUsYxVrKemOtMa3-BaAIIS25HBVJ7uQKIFHro4yZ28MK5Wo-AlUR21vOhh4xQ1ZCItiL5mQDWvXbxEBjc_D010YVnQEMI4c5Fh-6NeJNk-Tydgrl0Di_kLRN4nVfWcCM-H6v_fWJE6AXqlDGmwUj05AQXAPaCGlZ9PFEPdAMUhh-KyvMsKv3uYFa_EAa2bIMcuemAu-fLOeSjQIk21DjRbfoPpJL3_f2VXwFnwQ7Ix4wDwbgCs9njJqn7vJfoh9dn7P1k4GNBLBwGH--UpOkdSM3Tu9emUFkGtsSCUwoyS3VnBo2TQfxA_Ok7Pim2aQygIxYoSgwoAdTd9hoRimxfDY8LGbCODmLC3uEvf95ZAydpZmXuEaGjIBf6PAnUIAXZxLvmdX8zB9QTC5hkPZnYYfBkINLDu9dqCsiws4tEW71jWhIW7oAnEftWOHZGvx_36puv8n8qyadwAfgIk96x9j9kPxoHZEmUAd6hwg1sdqcj3uTYErejT3E8SAndMy_nucZ2U3g2b0ZkpipUYjGqMiu6o32QKbwxf8eDtWtsnX4NIzdW_rQqE2FGkxUAoK_0soY4ZAUMmDred81W3zN9KuMQ_8mRDK2HGh77I2QLyB4b8ZSqwq_Fj40re8o7MlSaO_1d9j5QQcggQw3xzJuopOCr-RyHWcfCn5oek9xe4c5nfg9tGQ5jY6Zh7wYVmEmTpar2GxO7_wiVBq8D8oM-0xrSduqHGSN0x5_VppDuTRH7qCUh__3IsSkUZKAaflxd34JNOkFFsIInXsuCGUNg14xmUJPJlsu_ZhBYyyLSbJT5TaBGwIZLoRbStXPf0KrAUh3juEXuhttayJpEIFFqKstMa_hIljJJrXbJ1Kj8esIa9WqzcVE990j-KGFTEcoqfeWYHQbAEpsRt9cYRGdjia4mt4y3jBVB4NhUKHqGPXWMAuCkrWr4XnqsQhxuxginQrXjtYn4_OJe9UIy4mfYKl5v8Pa2uLSQocZkcnqU1ucxtmzLCNMtOR3qJfwhqBoHO0RgZiWUzlsAih6EVRwknd2DiK83SO1xBxrFG3R_AeVL3e1OnfQXOIDb7lI45nXycAAk2ue5hkjwzW1T9XFISCzBcsysIf4PJdRBv9SkCgzOjIShVtcjW0u7L5AnJGAPT4dbUFrpSwynyYiN8-TxVWsfMiI5B4wQQT9BXzE35Lpmfjp0OEDYqgNPslqHlzCk6h0Eh1tGDw6vurzl8yeTTDvR1tYdSnQaoDWpnQGc31lj4WGjVopi9wnXKZzdK9Nizz-YYi1Yk; path=/; domain=.itwebapps.grinnell.edu;'
    cookie = raw_cookie.map { |b| b.collect { |key, val| format('%s=%s', key, val) }.join '; ' }.join '; '
    # puts cookie
    data = open('https://itwebapps.grinnell.edu/private/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=&LastName=&LNameSearch=startswith&FirstName=&FNameSearch=startswith&email=&campusphonenumber=&campusquery=&Homequery=&Department=&Major=&conc=&SGA=Loosehead+Senator&Hiatus=&Gyear=&submit_search=Search',
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
        elsif element.attr('colspan') == '1' && !(element.text.strip == 160.chr('UTF-8') || element.text.strip == '-')
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
    arr.map do |person|
    end
    # render data
    render json: {
      # errMessage: "",
      # content: [{

      # }]
      haha: arr
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
end
