require 'selenium-webdriver'
require 'pry'

namespace :site_crawler do
  task output: :environment do
    questions_hash = []
    questions = Question.where(energy: ..-1)
    questions.each do |question|
      questions_hash << {text: question.text, result: "外向"}
    end
    questions = Question.where(energy: 1..)
    questions.each do |question|
      questions_hash << {text: question.text, result: "内向"}
    end
    questions = Question.where(information: ..-1)
    questions.each do |question|
      questions_hash << {text: question.text, result: "感覚"}
    end
    questions = Question.where(information: 1..)
    questions.each do |question|
      questions_hash << {text: question.text, result: "直観"}
    end
    questions = Question.where(decision: ..-1)
    questions.each do |question|
      questions_hash << {text: question.text, result: "思考"}
    end
    questions = Question.where(decision: 1..)
    questions.each do |question|
      questions_hash << {text: question.text, result: "感情"}
    end
    questions = Question.where(response: ..-1)
    questions.each do |question|
      questions_hash << {text: question.text, result: "判断"}
    end
    questions = Question.where(response: 1..)
    questions.each do |question|
      questions_hash << {text: question.text, result: "知覚"}
    end

    text = "|Text|Result|\n|----|----|\n"
    questions_hash.shuffle.each do |question_hash|
      text += "|#{question_hash[:text]}|#{question_hash[:result]}|\n"
    end
    puts text
  end

  task run: :environment do
    Selenium::WebDriver.logger.level = :debug
    Selenium::WebDriver.logger.output = 'selenium.log'
    options = Selenium::WebDriver::Chrome::Options.new
    #options.add_argument('--headless')
    # options.add_argument('--disable-gpu')
    # options.add_argument("--no-sandbox")
    #Selenium::WebDriver::Chrome.driver_path = '/path/to/chromedriver'
    #Selenium::WebDriver::Chrome::Service.driver_path = '/opt/chromedriver'
    driver = Selenium::WebDriver.for :chrome, options: options

    driver.navigate.to "https://www.16personalities.com/ja/%E6%80%A7%E6%A0%BC%E8%A8%BA%E6%96%AD%E3%83%86%E3%82%B9%E3%83%88"


    60.times do |i|
      text = nil
      10.times do |j|
        questions_div = driver.find_element(:css, 'div.questions')
        question_field_sets = questions_div.find_elements(:tag_name,"fieldset")
        question_field_sets.each_with_index do |field_set, k|
          spans = field_set.find_element(:css, ".group__options").find_element(:css, ".radios").find_elements(:css, "span.sp-radio")
          if j * 6 + k == i
            text = field_set.find_element(:css, "div.input__label").text
            text = text.split(".\n")[1]
            span = spans[0]
          else
            span = spans[3]
          end
          span.click
          sleep 0.6
        end
        # 次へ
        driver.find_element(:xpath, '//*[@id="main-app"]/div[1]/div/form/div[2]/button').click
        sleep 1
      end
      driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[2]/button').click
      text_element = driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[1]/div/div/h3').text
      texts = text_element.split(" ")
      score = texts[0].to_i - 50
      if texts[1] == "内向型"
        energy = score - 1
      else
        energy = -score - 1
      end
      driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[2]/button').click

      text_element = driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[1]/div/div/h3').text
      texts = text_element.split(" ")
      score = texts[0].to_i - 50
      if texts[1] == "直感型"
        information = score - 1
      else
        information = -score - 1
      end
      driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[2]/button').click

      text_element = driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[1]/div/div/h3').text
      texts = text_element.split(" ")
      score = texts[0].to_i - 50
      if texts[1] == "感情型"
        decision = score - 3
      else
        decision = -score - 3
      end
      driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[2]/button').click

      text_element = driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[1]/div/div/h3').text
      texts = text_element.split(" ")
      score = texts[0].to_i - 50
      if texts[1] == "探索型"
        response = score - 3
      else
        response = -score - 3
      end
      driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[2]/button').click

      text_element = driver.find_element(:xpath, '//*[@id="quiz-results-cards"]/div/div/div/div[1]/div/div/h3').text
      texts = text_element.split(" ")
      score = texts[0].to_i - 50
      if texts[1] == "激動型"
        stress = score - 1
      else
        stress = -score - 1
      end

      question = Question.create!(text: text, energy: energy, information: information, decision: decision, response: response, stress:stress)
      p question
      driver.get('https://www.16personalities.com/ja/%E6%80%A7%E6%A0%BC%E8%A8%BA%E6%96%AD%E3%83%86%E3%82%B9%E3%83%88')
    end
  end
end
