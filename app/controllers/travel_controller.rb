class TravelController < ApplicationController
  def index
  end

  def search
    countries = find_country(params[:country])
    if countries.is_a?(Hash) && countries['error']
      flash[:alert] = countries['error']
      return render action: :index
    end
    unless countries && countries.is_a?(Array)
      flash[:alert] = 'Country not found'
      return render action: :index
    end
    @country = countries.first
    # puts @weather = find_weather(@country['capital'], @country['alpha2Code'])
  end

  def find_weather(city, country_code)
    query = URI.encode_www_form_component("#{city},#{country_code}")
    request_api(
      "https://community-open-weather-map.p.rapidapi.com/forecast?q=#{query}"
    )
  end

  def request_api(url)
    api_key = ENV['RAPIDAPI_API_KEY']
    return { 'error' => 'Falta la variable de entorno RAPIDAPI_API_KEY. Por favor, configúrala.' } unless api_key

    response = Excon.get(
      url,
      headers: {
        'X-RapidAPI-Host' => URI.parse(url).host,
        'X-RapidAPI-Key' => api_key
      }
    )
    if [401, 403].include?(response.status)
      return { 'error' => 'Clave de API inválida o sin permisos. Verifica tu RAPIDAPI_API_KEY.' }
    end
    return nil if response.status != 200

    JSON.parse(response.body)
  end

  def find_country(name)
    request_api(
      "https://restcountries-v1.p.rapidapi.com/name/#{URI.encode_www_form_component(name)}"
    )
  end
end
