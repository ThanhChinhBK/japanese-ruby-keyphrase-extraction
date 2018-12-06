require "tiny_segmenter"
require "page_rank"
require_relative "JPStemmer.rb"

class KeyphraseExtraction
  def initialize()
      @stopword = File.read('stopword.txt').split("\n")
      @punct = File.read('punct.txt').split("\n")
      @stemmer = JPStemmer.new
      @tokenizer = TinySegmenter.new
  end
  def extract_keyphrase(text)
      ranking_keyword(text)
    #   return @word_net
      @keywords = @word_net.keys()[0..20]
      @keyphrases = {}
      j = 0
      @word_list.each_with_index do |word, i|
          if i < j
              next
          end
          word = @stemmer.stemmer(word)
          if @keywords.include? word
              tmp = []
              tmpsum = 0
              c = 0
              for k in 0..10 do
                  l = i + k
                  if @word_list[l] == nil
                      next
                  end
                  break if @punct.include? @word_list[l]
                  w = @stemmer.stemmer(@word_list[l])
                  tmp.push(@word_list[l])
                  if @word_net.key?(w)
                    c += 1
                    tmpsum += @word_net[w]
                    @keyphrases[tmp.join("")] = tmpsum/ c
                  end
                  
                  j = i + tmp.count
              end
          end
        
      end
      @keyphrases = Hash[@keyphrases.sort_by { |k,v| -v }[0..40]]
  end
  
  def  extract_candidate_words(text)
      @word_list = @tokenizer.segment(text)
      @candidate_words = []
      @word_list.each do |word|
          word = word
          if !(@stopword.include? word)
              @candidate_words.push(word)
          end
      end
  end
  def ranking_keyword(text)
      extract_candidate_words(text)
      net = PageRank.new(strategy: :sparse, damping: 0.8, tolerance: 0.00001)
      @candidate_words.each_cons(2) do |gram|
          gram = gram.sort
          net.add(gram[0], gram[1])
      end
      @word_net =  net.calculate
  end
 end

# text = "このホテルは完璧な立地に位置している。 うるさくはありません。 ベッドは良かったですので、料理は私を注文しました。 ミニバー、コーヒー / 紅茶セット、部屋にある。 したければタバコをとることもできる。 スタッフはとてもフレンドリーで親切です。 テレビを見るのに好きな方に、国際プログラムが備わっているか、映画を見ることができます。 で、長い散歩した後、彼らのフットリラクゼーションマッサージお薦めである !
# おそらく、今まで泊まった最高のホテルのひとつです。 部屋は近代的で、広々していて、スタイリッシュでした。 はほこり一つないほど清潔で、私たちの部屋は、バルコニーがついていました市内の景色を見渡すことができる。 私たちは、素晴らしい朝食は、ホアンキエム湖を見渡す屋上にありました。 私たちはここに早く私たちの休暇に泊まりましたが、私たちが備わっている交換してくれましたと思いますが、私たちがもっと意見に賛成します妻とここで多くの日以上の滞在予定である。
# 私は友達と一緒に、十分なホテルはアプリコットハノイのホテルの研究している間を見つけることができて非常にラッキーでした。 私はこの素敵な場所を見つけるの私たちをとても幸運だと思いますがありません。 ファーストクラスの、高級ではありませんこのホテルは S は何もありません。 入った瞬間からは、設備も整っていてロビーに歩き、英語を話すスタッフが迎えてくれる。全てが高品質のにあるように思えました。 部屋自体はとても魅力的でした、比較的こぢんまりとしているが、私たちが必要とする全てのスペースも用意されている。 ワールドクラス - 朝食ビュッフェであることは言うまでもない。 この食品はどこに行くにも様々なありません。 私は、アプリコット &quot; ホテル。大変お勧めできません。 ここでは、ご滞在をお楽しみいただきます。 ません。言うまでもなく、ロケーションは、フレンチクォーターの徒歩圏内には、ショッピングモール、高級レストランにあり、コースがベトナムの素晴らしい人々と。
# "
text = File.read('example.txt')
kpe = KeyphraseExtraction.new()
a = kpe.extract_keyphrase(text)
a.each do |key, value|
  puts "#{key}:#{value}"
end