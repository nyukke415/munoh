#coding: utf-8

class Siritori

  def initialize()
    @plugin_name = "むのうしりとり"
    @turn = 0  #自分０   相手１
    @version = "2.0"
    @newWord = "" # 一番最新の単語を入れる
    @usedWord = [] # 使用済み
    @siritoriWord = [] # むのうの辞書
    @flag = true
    loadWord()
  end

  attr_reader :version, :plugin_name

  def main()
    puts "※ ひらがなのみ対応(異口同音禁止)"
    puts "むのう$ しりとりの「り」からスタート"
    @newWord = "しりとり" # 最初の単語はしりとり
    @usedWord.push(@newWord) # 使用済みに入れる
    while @flag do # 自分の番と相手の番を繰り返す
      if inputText() then
	@turn = 1
	outputText()
	@turn = 0
      end
    end
  end

  def inputText() # 自分の番
    print "あなた$ "
    newInput = gets.chomp # 入力をnewInputへ
    tailChange(newInput) # 最後の文字が「ぢ」の場合「じ」に変える、など
    if errorCheck(newInput) then #もししりとりが成り立っていれば
      @newWord = newInput
      @usedWord.push(@newWord)
      @siritoriWord.each{|array| # 辞書を漁って入力と同じ単語があれば削除
	array.delete(@newWord)
      }
      return true
    else
      return false
    end
  end

  def outputText() # 相手の番
    if wordSearch() then
      @usedWord.push(@newWord)
      print "むのう$ "
      puts @newWord
      if tailCheck(@newWord) == false
	gameOver()
      end
    end
  end

  def loadWord() # 単語を読み込んで @siritoriWordへ入れる
    # siritori.txtが入っている場所を指定
    open('./plugin/siritori/siritori.txt') { |file|
      while word = file.gets do
	line = word.split("\n")
	@siritoriWord.push(line[0].split(/ +/))
      end
    }
  end

  def tailChange(tail) # 語尾の処理
    list = [["ぢ", "じ"],["づ","ず"],["ぃ","い"],["ゃ","や"],["ゅ","ゆ"],["ょ","よ"],["ー",""]];
    list.each{|array|
      if tail[-1] == array[0] then
	tail[-1] = array[1];
	break;
      end
    }
  end

  def errorCheck(check) # しりとりが成り立っているか判定
    if !(headCheck(check) && tailCheck(check) && memoryCheck(check))
      gameOver() # 成り立っていなければゲームオーバー処理へ
      return false
    end
    return true # エラーがなければtrueを返す
  end

  # むのうの辞書の配列から単語を探す
  # 単語が見つかればその単語を辞書から削除しtrueを返す
  # 単語が見つからなければgameOverへ
  def wordSearch()
    @siritoriWord.each{|array|
      if array.empty? == false then
	if headCheck(array[0])  then
	  word = array[rand(array.length)]
	  tailChange(word)
	  @newWord = word
	  array.delete(@newWord)
	  return true
	end
      end
    }
    gameOver()
  end

  # 既に使っているかどうかを確認
  # 未使用：true 使用済み：false を返す
  def memoryCheck(newInput)
    if @usedWord.include?(newInput) then
      if @turn == 0
	puts "既に使った単語です"
      end
      return false
    else
      return true
    end
  end

  # 先頭の文字を確認
  # しりとりが成り立っている：true 成り立っていない：false
  def headCheck(str)
    if str[0]== @newWord[-1] then
      return true
    end
    if @turn == 0
      puts "しりとりが成り立ってません"
    end
    return false
  end

  # 語尾の確認
  # オッケー：true アウト：false
  def tailCheck(newInput)
    list = ["ん","っ"]
    list.each{|array|
      if(newInput[-1] == array) then
	if(@turn == 0) then
	  puts "語尾がアウトです"
	else
	  puts "むのう$ あっ・・・"
	end
	return false
      end
    }
    return true
  end

  def gameOver() # ゲームオーバー処理
    if @turn ==0 # もし自分のターンなら
      puts "続けますか？"
      puts "続ける...y    やめる...それ以外"
      cont = gets.chomp
      # ｙで続行
      if cont == "y" || cont == "ｙ" || cont == "Y" || cont == "Y" then
	print "むのう$ "
	puts @newWord
      else # それ以外なら終了
	puts "あなたの負けです"
        puts "しりとりを終了します"
        puts ""
	@flag =  false
      end
    else # もし相手のターンなら
      puts "あなたの勝ちです"
      puts "しりとりを終了します"
      puts
      @flag = false
    end
  end

end
## class end

siritori = Siritori.new()
outputText([loadConfig("system", "accept")[0]])
puts ""
print siritori.plugin_name
puts siritori.version

siritori.main()
