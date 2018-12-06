class JPStemmer
  def initialize()
    @endinglist = ["ませんでした", "ました", "ません", "ます", "ない", "なかった","ましょう"]
    @speciallist= ["おり","あび","浴び", "見ま", "起き","いま","借り","でき"]
    @nadjend = ["です", "だ", "でした", "だった", "ではありません", "ではない", "ではありませんでした", "ではなかった", "じゃない"]
    @iadjend = ["くなかった", "かった", "くない"]
    @wordlist = ["わ", "か", "が", "さ", "ざ", "た", "だ", "な", "ま", "は", "ば", "ぱ", "ら", "や"]
    @ilist = ["い", "き", "ぎ", "し", "じ", "ち", "ぢ", "に", "み", "ひ", "び", "ぴ", "り"]
    @ulist = ["う", "く", "ぐ", "す", "ず", "つ", "づ", "ぬ", "む", "ふ", "ぶ", "ぷ", "る", "ゆ"]
    @elist = ["え", "け", "げ", "せ", "ぜ", "て", "で", "ね", "め", "へ", "べ", "ぺ", "れ"]
    @olist = ["お", "こ", "ご", "そ", "ぞ", "と", "ど", "の", "も", "ほ", "ぼ", "ぽ", "ろ", "よ"]
    @tte = ["って", "った", "んで", "んだ", "いて", "いた", "きて", "いで", "いだ", "ぎで"]
    @word = ""
    @wordg = [""]
    @ending = ""
    @wordType = ""
    @original = ""
  end
  def stemmer(a)
    # a == the word
    @word = a
    @original = @word
    @word.strip()
    @gothrough = true
    step1()
    if @wordType == "vb"
        tmp = checkSpecial()
        if tmp
            return tmp
        end
    end
    if @wordg != [""]
      @word = @word[0...@word.size - @ending.size]
      if @wordType == "vb"
        step2()
        step3()
        step4()
        step5()
        step6()
        step7()
        step8()
      else
        step2a()
      end
    end
    return @word
  end
  def checkSpecial()
      for i in @speciallist
          if @word.start_with?(i)
              if i == "いま"
                  return "いる"
              elsif i == "見ま"
                  return "見る"
              else
                  return i + "る"
              end
         
          end
          
      end
      return false
  end
  def checkvb()
    checkEnd()
    checkPlain2()
    checkPlain1()
    checkCond()
    checkPot()
    checkCause()
    checkImp()
    checkVol()
    checkPass()
    checkTe()
  end
  def checkadj()
    for i in @iadjend
      if (@word[-1] == "い") && !@word.end_with?("じゃない")
        if @word[-2] != "な"
          @wordg = ["i", "adjective"]
          @ending = "い"
          return true
        else
          if @word[-3..-1] == "くない"
            @wordg = ["i", "adjective"]
            @ending = "くない"
            return true
          else
            return false
          end
        end
      end
      if @word.end_with?(i)
        if @word.end_with?("かった")
          if !@word.end_with?("くなかった")
            if @wordlist.include?(@word[-4])
              return false
            end
          end
        end
        @wordg = ["i", "adjective"]
        @ending = i
        return true
      else
        if @word.end_with?("じゃな" + i)
          @wordg = ["i", "adjective"]
          @ending = "じゃな" + i
          return true
        end
      end
    end
    for i in @nadjend
      if @word.end_with?(i)
        @wordg = ["na", "adjective"]
        @ending = i
      end
    end
  end
  def checkEnd()
    for i in @endinglist
      if @word.end_with?(i)
        if @ilist.include?(@word[(@original.size - i.size) - 1])
          if @word.end_with?("します")
            @wordg = ["shimasu", "normal"]
            @ending = "ます"
          else
            @wordg = ["one", "normal"]
            @ending = i
          end
        else
          if i == "ませんでした"
            @ending = i
            if @ilist.include?(@word[(-i.size) - 1])
              @wordg = ["one", "normal"]
              @ending = i
            else
              @wordg = ["two", "normal"]
              @ending = i
            end
          else
            if @wordlist.include?(@word[(@original.size - i.size) - 1])
              @wordg = ["one", "normal"]
              @ending = i
            else
              if @elist.include?(@word[(@original.size - i.size) - 1])
                @wordg = ["two", "normal"]
                @ending = i
              end
            end
          end
        end
      end
    end
  end
  def checkCond()
    for i in @elist
      if @word.end_with?(i + "ば")
        @wordg = ["two", "cond"]
        @ending = "ば"
      else
        if @word[-1] == "ば"
          @wordg = ["one", "cond"]
        end
      end
    end
  end
  def checkPlain1()
    if !@endinglist.include?(@ending)
      if @ulist.include?(@word[@original.size - 1])
        for i in @wordlist
          if @word.end_with?(i + "れる")
            @wordg = ["one", "pot"]
            @ending = "れる"
          end
        end
      end
      if @word.end_with?("られる")
        @wordg = ["two", "pot"]
        @ending = "られる"
      else
        if @wordg == []
          @wordg = ["one", "normal"]
          @ending = ""
        end
      end
    end
  end
  def checkPlain2()
    if @original.size == 2 && @word[1] == "る"
      @wordg = ["two", "normal"]
      @ending = "る"
    else
      if (@word[@original.size - 1] == "る") && (@elist.include?(@word[@original.size - 2])) && (!@wordlist.include?(@word[@original.size - 3]))
        @wordg = ["two", "normal"]
        @ending = "る"
        @ending = @word[@original.size - 1]
      end
    end
  end
  def checkCause()
    if @word.end_with?("せる")
      if @elist.include?(@word[-4])
        @wordg = ["two", "cause"]
        @ending = (@word[-4]) + "せる"
      else
        if @wordlist.include?(@word[-3])
          @wordg = ["one", "cause"]
          @ending = "せる"
        end
      end
    end
  end
  def checkPot()
    if @word.end_with?("られる")
      @wordg = ["two", "pot"]
      @ending = "られる"
    end
  end
  def checkImp()
    if @elist.include?(@word[-1])
      @wordg = ["one", "imp"]
      @ending = ""
    else
      if @word[-1] == "ろ"
        @wordg = ["two", "imp"]
        @ending = "ろ"
      end
    end
  end
  def checkVol()
    if @olist.include?(@word[-2])
      for i in @olist
        if @word.end_with?("よう")
          @wordg = ["two", "vol"]
          @ending = "よう"
        else
          if (@word.end_with?(i + "う")) && @wordg != ["two", "vol"]
            @wordg = ["one", "vol"]
            @ending = i + "う"
          end
        end
      end
    end
  end
  def checkPass()
    for i in @wordlist
      if @word.end_with?(i + "れる")
        @wordg = ["one", "pass"]
        @ending = "れる"
      end
    end
  end
  def checkTe()
    if @wordg == [""]
      for i in @tte
        if @word.end_with?(i)
          @wordg = ["one", "tte"]
          @ending = i
        else
          if @word.end_with?("て")
            @ending = "て"
          else
            if @word.end_with?("た")
              @ending = "た"
            end
          end
        end
      end
    end
  end
  def step1()
    if /[\u3040-ゟ]/.match(@word)
      if checkadj() == true
        @wordType = "adj"
      else
        @wordType = "vb"
        checkvb()
      end
    else
      @wordg = [""]
    end
  end
  def step2()
    if @wordg[1] == "normal"
      if (@wordg[0] == "two" && (!@ulist.include?(@word[-1]))) || (@word[-1] != "る")
        if @wordlist.include?(@word[@original.size - (@ending.size + 1)])
          @word = (@word[0...-1]) + (@ulist[@wordlist.index(@word[-1])])
        else
          if @ilist.include?(@word[@original.size - (@ending.size + 1)])
            @word = (@word[0...-1]) + (@ulist[@ilist.index(@word[-1])])
          end
        end
      end
      if @wordg[0] == "two"
        @word += "る"
      end
    end
    if @wordg[0] == "shimasu"
      @word += "る"
    end
  end
  def step2a()
    if @wordg[1] == "adjective"
      if @wordg[0] == "i"
        @word += "い"
      end
      if @wordg[0] == "na"
        @word -= @ending.size
      end
    end
  end
  def step3()
    if @wordg[1] == "tte"
      if @wordg[0] == "one"
        @word = @original
      else
        if @wordg[0] == "two"
          @word += "る"
        end
      end
    end
  end
  def step4()
    if @wordg[1] == "pot"
      if @wordg[0] == "one"
        # pass
      end
    end
  end
  def step5()
    if @wordg[1] == "imp" && @wordg[0] == "two"
      @word += "る"
    end
  end
  def step6()
    if @wordg[1] == "vol"
      if @wordg[0] == "one"
        @word += @ulist[@olist.index(@ending[0])]
      else
        if @wordg[0] == "two"
          @word += "る"
        end
      end
    end
  end
  def step7()
    if @wordg[1] == "pass"
      if @wordg[0] == "one"
        begin
        @word = (@word[0...-1]) + (@ulist[@wordlist.index(@word[-1])])
        rescue
        @word = @word[0...-1]
        ensure
        end
      end
    end
  end
  def step8()
    if @wordg[1] == "cause"
      if @wordg[0] == "one"
        begin
        @word = (@word[0...-1]) + (@ulist[@wordlist.index(@word[-1])])
        rescue
        @word = @word[0...-1]
        ensure
        end
    else
        if @wordg[0] == "two"
          @word += "る"
        end
      end
    end
  end
end
def stemming(w)
  stem = JPStemmer.new()
  return stem.stemmer(w)
end
# p stemming("あります")