require 'telegram/bot'
#require_relative 'config'
#token = TOKEN
token = '6619793393:AAFhfl7QCYokmORsMjf3te1O6Txai8wdTFA'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when 'start', '/start', '/start start'
      bot.api.send_message(
      chat_id: message.chat.id,
      text: "Здравствуй, #{message.from.first_name}. Позволь мне произвести расчет.
      Введи данные (сопротивление изоляции:  жила_1 - земля, жила_2 - земля, жила_1 - жила_2;
      сопротивление шлейфа пары, длина линии, диаметр жилы, температура)
      через пробел в виде 2356 2896 1923 200 4,5 0,9 25
      для перерасчета напиши << start >>"
      )
    else
      arr = message.text.split(' ')
      line_resistance_1 = arr[0].to_f
      line_resistance_2 = arr[1].to_f
      line_resistance_1_2 = arr[2].to_f
      lines_resistance = arr[3].to_f
      line_length = arr[4].to_f
     
      line_diameter = arr[5].to_f
      temperature = arr[6].to_f

      line_resistance_1_to_20 = line_resistance_1 / (1 + 0.006 * (temperature - 20))
      line_resistance_2_to_20 = line_resistance_2 / (1 + 0.006 * (temperature - 20))
      line_resistance_1_2_to_20 = line_resistance_1_2 / (1 + 0.006 * (temperature - 20))

      line_1_to_km = line_resistance_1_to_20 * line_length
      line_2_to_km = line_resistance_2_to_20 * line_length
      line_1_2_to_km = line_resistance_1_2_to_20 * line_length

      coefficient = 1 / (1 + 0.004 * (temperature - 20))

      lines_resistance_to_20 = lines_resistance * coefficient / line_length

      norm_for_lines = 46 / line_diameter**2

      norm_for_diameter = 0.23 / (line_diameter**2) * (line_length**0.5)

      begin
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Получи результат:
        1) Проверка электрического сопротивления изоляции 2.13.1                                                                                        
        
           Сопротивление  изоляции в МОм приведенное к температуре +20С 
             жила_1 - земля - #{line_resistance_1_to_20.round(0)}
             жила_2 - земля - #{line_resistance_2_to_20.round(0)}
             жила_1 - жила_2 - #{line_resistance_1_2_to_20.round(0)}

           Перерасчет электрического сопротивления 1 км изоляции жил кабеля, МОм/км
             жила_1 - земля - #{line_1_to_km.round(0) if line_1_to_km}
             жила_2 - земля - #{line_2_to_km.round(0) if line_2_to_km}
             жила_1 - жила_2 - #{line_1_2_to_km.round(0) if line_1_2_to_km}
        
        2) Измерение электрического сопротивления шлейфа пары 2.13.2
        
             Измерение электрического сопротивления шлейфа пары приведенное к температуре +20С, Ом/км
             #{lines_resistance_to_20.round(0)}
        
             Норма для данного кабеля Инф1-Инф2 (R шл/км <= 46/d2)
             не более #{norm_for_lines.round(0) if norm_for_lines}

        3) Измерение омической асимметрии пар 2.13.3 , Ом
        
             Норма для данного кабеля Инф1-Инф2(Δr <= 0,23/d2*√L)
             не более #{norm_for_diameter.round(1) if norm_for_diameter}"
      )
      rescue
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Введи корректные данные")
      end
    end
  end
end
