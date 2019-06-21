# -*- coding: utf-8 -*-
# last updated:<2017/02/22/Wed 19:07:28 from:biela-lenovo-s510>

$OS
VERSION = "4.5"
ENCODING_LIST = {:windows => "Windows-31J", :linux => "UTF-8"}
$characterList
$confDir = ["./config/*", "./plugin/*/*"] # 設定ファイルの保存場所
$pluginDir = "./plugin/"        # プラグインファイルの保存場所
$characterDir = "./character/*" # 人格データの保存場所
$character                       # 選択した人格を格納する
$head = []                       # 文頭の語を格納
$vocabulary = []                 # 文頭以外の語を格納
$input                        # ユーザが直前に入力した文章を格納(配列)
$preInput = []                # 過去にユーザが入力した文章を格納

# inputcheck で特別な語が含まれていたかどうか
# 含まれていれば true にする
# false なら文章を文章を作って画面に出力する
# 文章を作りたくないなら true にする
$flag = false

# 設定ファイルの = の左側と右側を格納する
# $confList の構造
# ["設定ファイル名" [["左側", [右側を空白でsplitしたもの]], [], ...],
#  "設定ファイル名" [["左側", [右側を空白でsplitしたもの]], [], ...],
#  ...]
$confList = []

# 読み込まれた設定ファイル名の一覧
$loadedConfList = ""

# むのうが作る文章が以下の語数を超えたら
# "tail"を見つけたら文章の作成を終了するようにする
$borderNumOfWord = 5

# main ################################################################
def main()
  init()

  # ################################################################
  # ################################################################
  # p "confList"
  # p $confList
  # print "\n"
  # ################################################################
  # ################################################################


  while 1 do
    $input = getInputText()
    $input = $input.inputCheck(loadConfig("trap")).textToArray()
    if $flag == false then      # inputCheck にかかっていないなら
      $preInput.push($input)     # ユーザの入力履歴を保存
      $input.learnWord()         # ユーザの入力を学習する
      outputText(makeSentence($preInput)) # 文章を作り画面に出力する
    else                                  # inputCheck にかかったなら
    end
  end
end

# function ################################################################
# 初期設定
def init()
  detectOS()
  setConfig()
  message()
  selectCharacter()
  storeDataToArray($character)
  autoStart()
end

# OS を検出する
def detectOS()
  $OS ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /linux/
      :linux
    else
      :unknown
    end
  )
end

# 設定を読み込む
def setConfig()
  # $confList
  # 複数の設定ファイルを読み込む
  Dir.glob($confDir).map {|confFile|
    if confFile.split(/\./)[-1] == "conf" then # 拡張子が "conf" のものだけ読む
      $loadedConfList += confFile + "\n"
      open(confFile) { |target|                # 設定ファイルごと
        $confList.push(File.basename(target).split(/\./)[0])
        $confList.push([])
        # 設定ファイル内のすべての行を読み込み
        while conf = target.gets do
          # next if(/^ *\n$/ =~ conf)
          next if(/^ *\n$/ =~ conf || /^#.*\n$/ =~ conf)
          conf = conf.delete("\n").split(/#/)[0]
          if conf.split(/ *= */, 2).length == 2 then
            $confList[-1].push([conf.split(/ *= */, 2)[0]])
            $confList[-1][-1].push(conf.split(/ *= */, 2)[1].split(/ +/))
          end
        end
      }
    end
  }
end

# バージョンなどを表示する
def message()
  print "\n\e[30;43;1m                                                  \e[m\n"
  print "\e[30;43;1m                  munoh  ver." + VERSION + "                  \e[m\n"
  print "\e[30;43;1m                                                  \e[m\n\n"

  print "\e[33m=================  config files  =================\e[m\n\e[34m"
  print $loadedConfList
  print "\e[m\n"

  print "\e[33m=================    plugins     =================\e[m\n\e[34m"
  Dir.glob($pluginDir + "*/*").map {|pluginFile| # 複数の設定ファイルを読み込む
    path =  pluginFile.split(/\./)[-2].split(/\//)
    # 拡張子が "rb" で属するディレクトリ名とファイル名が同じなら
    if path[-1] == path[-2] && pluginFile.split(/\./)[-1] == "rb" then
      print pluginFile + "\n"
    end
  }
  print "\e[m\n"
end

# 人格データを選択する
def selectCharacter()
  # 人格データの読み込み
  $characterList = Dir.glob($characterDir)
  # 人格データの一覧を表示
  print "\e[33m=================   characters   =================\e[m\n\e[34m"
  for i in 1..$characterList.length
    # print i.to_s + ":" + $characterList[i-1].split("/")[-1] + "\n"
    print i.to_s + ": " + $characterList[i-1] + "\n"
  end
  print "\e[m\nchose character: "
  num = gets.chomp.to_i - 1
  if 0 <= num && num < $characterList.length then
    $character = $characterList[num]

    print "\e[32mcharacter " + \
          $characterList[num].split("/")[-1].split("\.")[0] + "\e[m\n"

    nowLoadin()

    else
    print "\e[31mエラーが発生しましたもう一度入力して下さい\e[m\n\n"
    selectCharacter()
  end
end

# 設定ファイルに autoStart = true と書かれたものがあればそれを実行
def autoStart()
  i = 1
  while i < $confList.length do
    $confList[i].each { |conf|
      if conf[0] == "autoStart" && conf[1] == ["true"] then
        executePlugin($confList[i-1])
      end
    }
    i += 2
  end
end

def nowLoadin()
  print("Now Loading ")
  for i in 1..30 do
    if i != 7 then
      sleep(0.2 - (rand(0.05..0.1) + rand(0.05..0.1)))
    else
      sleep(0.8)
    end
    print(".")
    i += 1
  end
  print("\e[32m [OK]\e[m\n\n")
end

# ユーザー入力関連
def getInputText()
  print "\e[36;1m" + loadConfig("system", "userName")[0] + "\e[m: "
  input = gets.chomp.encode("UTF-8", ENCODING_LIST[$OS])
  return input
end

# むのうが画面にテキストを出力する
def outputText(array)
  print "\e[35;1m" + loadConfig("system", "munohName")[0] + "\e[m: "
  ("\e[35m" + array.join("") + "\e[m").showText()
end

# 文章を作成する(受け取った2次元配列で作る文章に補正をかける)
def makeSentence(array)
  count = 0
  res = []                      # 作成する文章を格納
  res.push($head[rand($head.length)]) # 文頭の言葉を選択



  # 本文を作る
  while 1 do
    # 直前に使用された語と対応する $vocabulary の1次元配列
    array = $vocabulary[$vocabulary.searchIndex(res[-1], 1)]
    # $vocabulary が空なら
    if array == nil then
      return [""]
    end
    # 語数が $borderNumOfWord を超えたら文章を終了させやすくする
    if $borderNumOfWord < count then
      if searchNextWordInArray(array, "tail") == -1 then
        res.push(markov(array))
      else                      # tail が見つかれば
        break
      end
    else                        # 語数が $borderNumOfWord を超えていないなら
      res.push(markov(array))
    end
    if res[-1] == "tail" then   # 語尾に tail がくっついていれば
      res.delete_at(-1)
      break
    end
    count += 1
  end
  return res
end

# 文字列を受け取り品詞を返す
def returnPartOfSpeech(str)
  if(str != "") then
    `echo #{str} | mecab -d #{loadConfig("system", "dicPath")[0]}`.split("\n")[0].split("\t")[1].split(",")[0].encode("UTF-8", ENCODING_LIST[$OS])
  else
    return ""
  end
end

# $vocabulary[i] を受け取りマルコフ連鎖でどの語を使用するかを決定する
def markov(array)
  sum = rand(array[0].to_i) + 1
  i = 2
  while i < array.length do
    sum -= array[i].to_i
    if sum <= 0 then
      return array[i+1]
    end
    i += 2
  end
end

# 1次元配列に文字列の要素があるか探す(あり:要素番号、なし:-1)
def searchNextWordInArray(array, word)
  i = 3
  while(i < array.length) do
    return i if(array[i] == word)
    i += 2
  end
  return -1
end

# 人格データを読み込み配列に格納する
def storeDataToArray(character)
  flag = false                  # 人格かheadのどちらを読み込んでいるか
  open(character) { |character|
    while data = character.gets do
      next if(/^ *\n$/ =~ data)
      if "@@@@ head @@@@\n" == data then
        flag = true
        next
      end
      if flag == false then
        $vocabulary.push(data.chomp.split(/ +/))
      else
        data = data.delete("\n").split(/#/)[0]
        $head.push(data)
      end
    end
  }
end

# ユーザが入力した文章を渡してその中の語に反応してプログラムを実行する関数
# programList の中にある語に反応する
def executeProgram()
  loadConfig("programList").each { |array|
    if array[0].split("-")[-1] == "trap"then
      array[1].each { |word|
        if $input.include?(word) == true then
          outputText([loadConfig("system", "accept")[0]])
          system(loadConfig("programList", array[0].split("-")[0])[0] +
                 " 2>/dev/null &")
          return true
        end
      }
    end
  }
  $flag = false
  return false
end

# プラグイン名を受け取りそのプラグインを実行
def executePlugin(name)
  load $pluginDir + name + "/" + name + ".rb"
end

# plugin とそれに対応する trap を表示する
def showPlugin()
  print "\e[33m=================    plugins     =================\e[m\n\e[34m"
  i = 0
  while i < $confList.length do
    pluginName = loadConfig($confList[i], "pluginName")[0]
    if pluginName != nil then
      print "plugin name: " + pluginName + "\n"
      print "trap       : "
      loadConfig($confList[i], "trap").map { |string|
        print string + "  "
      }
      print "\n\n"
    end
    i += 2
  end
  print "\e[m"
end

# $confList から指定されたデータを読み込む
def loadConfig(file, index = -1)
  if index != -1 then           # index が指定されていれば
    $confList[$confList.index(file) + 1].each { |array|
      if array[0] == index then
        return array[1]
      end
    }
  # index が指定されていなければ file で指定したファイルから読み込んだ
  # 設定が入った配列を返す
  else
    return $confList[$confList.index(file) + 1]
  end
  return []
end

# 終了時に呼び出す関数
def goodBye(flag = true)
  saveVocabulary($character, $vocabulary, $head)

  if flag then
    outputText(["バイバイ"])
  end
  exit
end

# 2次元配列をスペースで区切ってターゲットに保存してから
# head をファイル末尾に追記する (人格ファイル専用の関数)
def saveVocabulary(target, vocabulary, head)
  open(target, 'w') { |target|
    # 人格ファイル
    vocabulary.each { |array|
      target.puts(array.join(" "))
    }

    target.puts("")
    target.puts("@@@@ head @@@@")
    target.puts("")

    # head
    head.each { |str|
      target.puts(str)
    }
  }
end

# class ################################################################
class String
  # 配列を受け取りその配列の言葉とselfが一致したら対応する関数を実行
  def inputCheck(array)
    $flag = false
    return self unless self
    array.each{ |matchList|
      matchList[1].each{ |pattern|
        if self.match(pattern) != nil then
          $flag = true
          if eval(matchList[0]) == true then
            return self
          end
        end
      }
    }
    # 読み込んだ設定ファイルの trap をすべて検索し self と一致すれば
    # 対応する関数を実行する(プラグイン)
    i = 0
    while i < $confList.length do
      loadConfig($confList[i], "trap").each { |pattern|
        if $input =~ /#{pattern}/ then
          executePlugin($confList[i])
        end
      }
      i += 2
    end

    self                        # 戻り値は self
  end

  # 文字列中の(*, ^, $, .) を削除する
  def deleteRegexpChar()
    pattern = ["*", "^", ".", "$", "?", "(", ")", "|"]
    str = self
    i = 0
    while i < str.length do
      if str[i]== "\\" then
        str = str[0..i-1] + str[i+1..-1]
      else
        if pattern.include?(str[i]) == true then
          if i == 0 then
            str = str[1..-1]
          elsif i == str.length then
            str = str[0..i-1]
          else
            str = str[0..i-1] + str[i+1..-1]
          end
          i -= 1
        end
      end

      i += 1
    end

    return str
  end

  # 入力された文字列をMecabでバラして配列に格納
  def textToArray()
    if(self != "") then
      `echo #{self} | mecab -d #{loadConfig("system", "dicPath")[0]}`.split("\n")[0..-2].map { |s|
        s.split("\t")[0].encode("UTF-8", ENCODING_LIST[$OS])
      }
    else
      return []
    end
  end

  # Windows-31Jに変換してから表示
  def showText()
    puts self.encode(ENCODING_LIST[$OS], "UTF-8")
  end
end

class Array
  # ユーザが入力した文章を学習する
  def learnWord()
    # $head の学習
    $head.push(self[0]) if (self != [] && $head.include?(self[0]) == false)

    # $vocabulary の学習
    (0..(self.length - 1)).each{|i|
      word = self[i]
      nextWord = (self.length == i + 1)? "tail": self[i + 1]
      index = $vocabulary.searchIndex(word, 1)
      if(index == -1) then      # 学習したことのない新規の語なら
        $vocabulary.push(["1", word, "1", nextWord])
      else                      # 学習したことがある語なら
        array = $vocabulary[index]
        pos = searchNextWordInArray(array, nextWord)
        if(pos == -1) then      # 初めて連続した語なら
          array.push("1", nextWord)
        else                    # すでに連続したことがある語なら
          array[pos - 1] = (array[pos - 1].to_i + 1).to_s
        end
        # $vocabulary[index][1]の出現回数を更新
        array[0] = (array[0].to_i + 1).to_s
        # $vocabulary に更新した1次元配列を push する
        $vocabulary.delete_at(index)
        $vocabulary.push(array)
      end
    }
  end

  # 2次元配列[i][j]に word があるか探す(あり:配列番号、なし:-1)(行番号を探す)
  def searchIndex(word, j)
    i = self.length - 1         # array の後ろから検索する
    while(-1 < i && self[i][j] != word) do i -= 1 end
    return i
  end
end

main()
