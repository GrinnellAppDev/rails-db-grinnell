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
    c = '.AspNet.Cookies=C-eEJXdnjY2BrPiNQaTahxqjs-YFBHiEdsR_s97dGtqTRmmgFG8hZGTNzK19rOsJo4u1sHDGVBa3pR3ypKrKsJRHtLRKktkLL9x-9rqlO2DWS8ZxWDqF7cNLBwONkQEuF7EIukHsTDu4NApCcztvnFDwAWm6SketSjtJ6pehpMgiZ--V6XfBoBzGPsG-TvLPkJN5zolITSKF4upXHZJ2jky1x-HreIntH8E88fDoCF3b5YMmpyy36dDvBFN3NE1QXAA-r-KiWvcNnwgzmyRPBJQPrE_r4MROSrrw1x4SwxtWD4f-3MwYEvTMQS-nAPjs7tGeeCdy7GH9JM9A2Rn8Ni_OsuUh5RckxsL6VtO5eUvT4ahHqw-FuCqOx6erJyw95rlMCJ65c3cjXHLxnAwQ7MVDAVQgMfFVu3XBX6afhF-MK--7s5Bc_WwYrxQhFA5AsH66_BG0ehtRyJaL_TzeqFJhdmtYKEui7gHNjEZ7_4zgSXrrdIfRGE-XoMkRJfI_4NoCVJ48bp35i2AsCntx0ZAvHjrl3mh7m2OIN-HWMlZSRhfubTUKY11cAHUHFgQJhG6d0w7TpPMl5iBS6pVtR2yrrNFsT-QUx13ddgSRiWUIK5-EDdU8qb4IiotK3jMNuzAodpCaWRFJDEzuBTS6v9-yr9Ykigf978PwG3YlCyfCPlzUKV3neG5u0RtQeEuJrQ4wXBWWo3UAQG5t1GkVMdmH0hWwZoI2ozfRD8wsJCMU8pidi8tHmI05cQA9G_qp0jgH5Khj5nNIzM9JPqVHYcpbRp91d6CqxHVn0itUkBHjdXD14WNFnltRrlq12rZkPwydnC5ltIaIOCnbyz79vqycmD31vb5PS24EE3L6lsXfA0sK5DVBaNDAtyXdsIVDSUkR2jjXTNuxhyMcncloYVriUf70gwB7xU4Q3RU0n8YEXYkvLyKmJUH6xQ4ki1QNPD5BCl51OIUjQVozAQ6v4T4xTloxuc8lcwN-9Um1j3-vI_f4pfXBVDYLFNrGthPAsSOD2hT0fhd2s9CTBxjh0j3Z1pYu8xIYwPfuKbQ1jiKCOY11LP-Ywr4tbA6tkhWpCXGDLdSbuEjC88rlQFfZh3_96SBRvJE9_H4WtRw3AluEbyXfji1NiA0BB6Ch6zsr0lXfpftLp8P23Y6Nujgpm5uA7-rF9y2JaTTfGvo0L9uNPgB9c-hyBcPpw1uW-Aeu4h12pPg3qcJaFXMc3aSvjZAMlxZC_sw_BASo8Ho8SA4jB7IBQHNDMiCEy9az_OW9uuHBvBD2kFJ_Mtzk2KUU2CGYh3YVcAp0JPEVTLJQ95vI16WlodM5fCfFdRKlFGLYg-JRQX5Ph1mYJFzD42aTmSN7S1AktqeheE5sRY4KRTSLgzz-puqGZ1TTIkotvka5Q9DmwCeT21OkPMRWwaLIjvMyR-n52XRbTwuugd_2_Kg; path=/; domain=.itwebapps.grinnell.edu;'
    cookie = raw_cookie.map { |b| b.collect { |key, val| format('%s=%s', key, val) }.join '; ' }.join '; '
    # puts cookie
    data = open('https://itwebapps.grinnell.edu/private/asp/campusdirectory/GCdefault.asp?transmit=true&blackboardref=&LastName=hong&LNameSearch=startswith&FirstName=&FNameSearch=startswith&email=&campusphonenumber=&campusquery=&Homequery=&Department=&Major=&conc=&SGA=&Hiatus=&Gyear=&submit_search=Search',
                'Cookie' => c,
                'User-Agent' => 'Mozilla/5.0',
                'Referer' => 'https://login.microsoftonline.com/',
                'Origin' => 'https://login.microsoftonline.com').read

    doc = Nokogiri::HTML(data)
    puts doc.title
    tag = {}
    arr = []
    i = 0
    comp = 'On Campus ViewUsers may not send anonymous mail, mail with altered headers giving erroneous information, or anonymous files.'
    istext = false
    doc.css('td').each_with_index do |element, index|
      if istext && (element.text.strip != 'New Search')

        if (i % 8).zero?
          arr << element
        else
          arr[i / 8] << element
        end
        i += 1
        if index == 9
          tag[9] = getname(element)
        else
          tag[index] = element.text.strip
        end

      elsif istext && (element.text.strip == 'New Search')
        break
      elsif element.text.strip == comp
        istext = true
      end
    end

    # convert the arr into a list of person
    # render data
    render json: {
      # errMessage: "",
      # content: [{

      # }]
      haha: arr.map { |x| x.text.strip }
    }
  end

  private

  def getname(noko)
    [noko.text.strip, noko.css('a')[0]['href']]
  end

  def getmajor(noko)
    noko.text.strip
  end

  def getPhone(noko)
    noko.text.strip
  end

  def getEmail(noko)
    noko.text.strip
  end

  def getAdress(noko)
    noko.text.strip
  end

  def getBox(noko)
    noko.text.strip
  end

  def getStatus(noko)
    noko.text.strip
  end
end
