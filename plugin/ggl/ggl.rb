# -*- coding: utf-8 -*-
# last updated:<2017/02/22/Wed 19:02:25 from:biela-lenovo-s510>

# ググる
class Ggl
  def initialize()
    @plugin_name = "ggl";
  end

  def main()
    $flag = true
    loadConfig("ggl", "trap").each { |trap|
      if /#{trap}/ =~ $input then
        @word = $input.delete(trap.deleteRegexpChar)
        break
      end
    }
    @browser = loadConfig("programList", "browser")[0]
    @url = " '" + loadConfig(@plugin_name, "url")[0]

    system(@browser + @url + @word + "' &")
    outputText([loadConfig("system", "accept")[0]])
  end

end

ggl = Ggl.new()
ggl.main()
