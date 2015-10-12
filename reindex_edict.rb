# This script will take the 'editc2u' file, parse each entry, and send them to ES.
#
# Resources:
#   * http://www.jedict.com/

require 'pp'
require 'json'

IP_ADDR = `ifconfig wlan0 | grep inet | cut -d':' -f2 | cut -d 'B' -f1`
ES_HOST="http://localhost:9200"

# Check if Elasticsearch is running yet
`curl -s -i localhost:9200 | grep "status" | grep 200 1>/dev/null || echo 1`
unless $?.success?
	raise "Elasticsearch not running! Might still be booting up. Check http://#{IP_ADDR}:9200 and try again."
end

# Via http://www.edrdg.org/wwwjdic/wwwjdicinf.html#code_tag + http://nihongo.monash.edu/dictionarycodes.html
CODE_DICTIONARY = {"abbr"=>"abbreviation", "adj-f"=>"noun or verb acting prenominally (other than adj-na, etc.)", "adj-i"=>"adjective (keiyoushi)", "adj-kari"=>"'kari' adjective (archaic)", "adj-ku"=>"'ku' adjective (archaic)", "adj-na"=>"adjectival nouns or quasi-adjectives (keiyodoshi)", "adj-nari"=>"archaic/formal form of na-adjective", "adj-no"=>"nouns which may take the genitive case particle ''no\"", "adj-pn"=>"pre-noun adjectival (rentaishi)", "adj-s"=>"special adjective (e.g. ookii)", "adj-shiku"=>"'shiku' adjective (archaic)", "adj-t"=>"\"taru\" adjective", "adv"=>"adverb (fukushi)", "adv-n"=>"adverbial noun", "adv-to"=>"adverb taking the \"to\" particle", "an"=>"adjectival noun (keiyoudoushi)", "anat"=>"anatomical term", "arch"=>"archaism", "archit"=>"architecture term", "astron"=>"astronomy, etc. term", "ateji"=>"ateji reading", "aux"=>"auxiliary", "aux-adj"=>"auxiliary adjective", "aux-v"=>"auxiliary verb", "baseb"=>"baseball term", "biol"=>"biology term", "bot"=>"botany term", "Buddh"=>"Buddhist term", "bus"=>"business term", "c"=>"company name (ENAMDICT)", "chem"=>"chemistry term", "chn"=>"children's language", "col"=>"colloquialism", "comp"=>"computer terminology", "conj"=>"conjunction", "ctr"=>"counter", "derog"=>"derogatory word or expression", "econ"=>"economics term", "eK"=>"exclusively written in kanji", "engr"=>"engineering term", "exp"=>"Expressions (phrases, clauses, etc.)", "f"=>"female given name (ENAMDICT)", "fam"=>"familiar language", "fem"=>"female term or language", "finc"=>"finance term", "food"=>"food term", "g"=>"given name, as-yet not classified by sex (ENAMDICT)", "geol"=>"geology, etc. term", "geom"=>"geometry term", "gikun"=>"gikun (meaning) reading", "gram"=>"grammatical term", "h"=>"full (family plus given) name of a person (ENAMDICT)", "hob"=>"Hokkaido-ben", "hon"=>"honorific or respectful (sonkeigo) language", "hum"=>"humble (kenjougo) language", "id"=>"idiomatic expression", "ik"=>"word containing irregular kana usage", "iK"=>"word containing irregular kanji usage", "int"=>"interjection (kandoushi)", "io"=>"irregular okurigana usage", "iv"=>"irregular verb", "joc"=>"jocular, humorous term", "ksb"=>"Kansai-ben", "ktb"=>"Kantou-ben", "kyb"=>"Kyoto-ben", "kyu"=>"Kyuushuu-ben", "law"=>"law, etc. term", "ling"=>"linguistics terminology", "m"=>"male given name (ENAMDICT)", "m-sl"=>"manga slang", "MA"=>"martial arts term", "male"=>"male term or language", "male-sl"=>"male slang", "math"=>"mathematics", "med"=>"medicine, etc. term", "mil"=>"military", "music"=>"music term", "n"=>"noun (common) (futsuumeishi)", "n-adv"=>"adverbial noun (fukushitekimeishi)", "n-pr"=>"proper noun", "n-pref"=>"noun, used as a prefix", "n-suf"=>"noun, used as a suffix", "n-t"=>"noun (temporal) (jisoumeishi)", "nab"=>"Nagano-ben", "neg"=>"negative (in a negative sentence, or with negative verb)", "neg-v"=>"negative verb (when used with)", "num"=>"numeral", "o"=>"organization name (ENAMDICT)", "obs"=>"obsolete term", "obsc"=>"obscure term", "ok"=>"out-dated or obsolete kana usage", "oK"=>"word containing out-dated kanji", "on-mim"=>"onomatopoeic or mimetic word", "osb"=>"Osaka-ben", "p"=>"place-name (ENAMDICT)", "physics"=>"physics terminology", "pn"=>"pronoun", "poet"=>"poetical term", "pol"=>"polite (teineigo) language", "pr"=>"product name (ENAMDICT)", "pref"=>"prefix", "proverb"=>"proverb", "prt"=>"particle", "qv"=>"quod vide (see another entry)", "rare"=>"rare", "rkb"=>"Ryukyuan language", "s"=>"surname (ENAMDICT)", "sens"=>"sensitive", "Shinto"=>"Shinto term", "sl"=>"slang", "sports"=>"sports term", "st"=>"station name (ENAMDICT)", "suf"=>"suffix", "sumo"=>"sumo term", "thb"=>"Touhoku-ben", "tsb"=>"Tosa-ben", "tsug"=>"Tsugaru-ben", "u"=>"as-yet unclassified name (ENAMDICT)", "uk"=>"word usually written using kana alone", "uK"=>"word usually written using kanji alone", "v-unspec"=>"verb unspecified", "v1"=>"Ichidan verb", "v2a-s"=>"Nidan verb with 'u' ending (archaic)", "v2b-k"=>"Nidan verb (upper class) with 'bu' ending (archaic)", "v2b-s"=>"Nidan verb (lower class) with 'bu' ending (archaic)", "v2d-k"=>"Nidan verb (upper class) with 'dzu' ending (archaic)", "v2d-s"=>"Nidan verb (lower class) with 'dzu' ending (archaic)", "v2g-k"=>"Nidan verb (upper class) with 'gu' ending (archaic)", "v2g-s"=>"Nidan verb (lower class) with 'gu' ending (archaic)", "v2h-k"=>"Nidan verb (upper class) with 'hu/fu' ending (archaic)", "v2h-s"=>"Nidan verb (lower class) with 'hu/fu' ending (archaic)", "v2k-k"=>"Nidan verb (upper class) with 'ku' ending (archaic)", "v2k-s"=>"Nidan verb (lower class) with 'ku' ending (archaic)", "v2m-k"=>"Nidan verb (upper class) with 'mu' ending (archaic)", "v2m-s"=>"Nidan verb (lower class) with 'mu' ending (archaic)", "v2n-s"=>"Nidan verb (lower class) with 'nu' ending (archaic)", "v2r-k"=>"Nidan verb (upper class) with 'ru' ending (archaic)", "v2r-s"=>"Nidan verb (lower class) with 'ru' ending (archaic)", "v2s-s"=>"Nidan verb (lower class) with 'su' ending (archaic)", "v2t-k"=>"Nidan verb (upper class) with 'tsu' ending (archaic)", "v2t-s"=>"Nidan verb (lower class) with 'tsu' ending (archaic)", "v2w-s"=>"Nidan verb (lower class) with 'u' ending and 'we' conjugation (archaic)", "v2y-k"=>"Nidan verb (upper class) with 'yu' ending (archaic)", "v2y-s"=>"Nidan verb (lower class) with 'yu' ending (archaic)", "v2z-s"=>"Nidan verb (lower class) with 'zu' ending (archaic)", "v4b"=>"Yodan verb with 'bu' ending (archaic)", "v4g"=>"Yodan verb with 'gu' ending (archaic)", "v4h"=>"Yondan verb with 'hu/fu' ending (archaic)", "v4k"=>"Yodan verb with 'ku' ending (archaic)", "v4m"=>"Yodan verb with 'mu' ending (archaic)", "v4n"=>"Yodan verb with 'nu' ending (archaic)", "v4r"=>"Yondan verb with 'ru' ending (archaic)", "v4s"=>"Yodan verb with 'su' ending (archaic)", "v4t"=>"Yodan verb with 'tsu' ending (archaic)", "v5aru"=>"Godan verb - -aru special class", "v5b"=>"Godan verb with 'bu' ending", "v5g"=>"Godan verb with 'gu' ending", "v5k"=>"Godan verb with 'ku' ending", "v5k-s"=>"Godan verb - Iku/Yuku special class", "v5m"=>"Godan verb with 'mu' ending", "v5n"=>"Godan verb with 'nu' ending", "v5r"=>"Godan verb with 'ru' ending", "v5r-i"=>"Godan verb with 'ru' ending (irregular)", "v5s"=>"Godan verb with 'su' ending", "v5t"=>"Godan verb with 'tsu' ending", "v5u"=>"Godan verb with 'u' ending", "v5u-s"=>"Godan verb with 'u' ending (special class)", "v5uru"=>"Godan verb - Uru old class verb (old form of Eru)", "v5z"=>"Godan verb with 'zu' ending", "vi"=>"intransitive verb", "vk"=>"Kuru verb - special class", "vn"=>"irregular nu verb", "vr"=>"irregular ru verb, plain form ends with -ri", "vs"=>"noun or participle which takes the aux. verb suru", "vs-c"=>"su verb - precursor to the modern suru", "vs-i"=>"suru verb - irregular", "vs-s"=>"suru verb - special class", "vt"=>"transitive verb", "vulg"=>"vulgar expression or word", "vz"=>"Ichidan verb - -zuru special class (alternative form of -jiru verbs)", "X"=>"rude or X-rated term (not displayed in educational software)", "zool"=>"zoology term"}

# Get ready to match tags from a string ("(n)", "(adj)", etc)
CODES_REGEXP = CODE_DICTIONARY.keys.map { |c| Regexp.escape(c) }.join("|")

def send_mapping_to_es
	# Reset index
	puts "Deleting /edict index..."
	`curl -s -XDELETE #{ES_HOST}/edict`
	puts "Creating /edict index..."
	`curl -s -XPUT #{ES_HOST}/edict`

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-core-types.html
  mapping = {
  	entry: {
  		properties: {
  			kanji: {type: "string", store: true}, # array of strings
  			kana: {type: "string", store: true},  # array of strings
  			codes: {type: "string", store: true},
  			codes_meanings: {type: "string", store: true}, # array of strings
  			meanings: {type: "string", store: true},
  			file_line: {type: "string", store: true},
  			file_lineno: {type: "integer", store: true}
  		}
  	}
	}

	puts "Creating /edict mapping..."
	cmd = "curl -s -XPUT #{ES_HOST}/edict/_mapping/entry -d '#{mapping.to_json}'"
	begin
		result = JSON.parse `#{cmd}`
	rescue => e
		puts cmd
		raise e
	end

	throw "Failure! #{cmd}" unless $?.success?
end

def send_entry_to_es(entry)
	cmd = "curl -s -XPUT #{ES_HOST}/edict/entry/#{entry[:file_lineno]} -d '#{entry.to_json.gsub(/'/, "")}'"
	result = JSON.parse `#{cmd}`

	throw "Failure! #{cmd} -> #{result.inspect}" if !$?.success? || !result['created']
end


send_mapping_to_es

lines = File.read('edict2u').lines.to_a

puts "Sending #{lines.size} entries to /edicts..."
lines.tap(&:shift).compact.map(&:strip).each.with_index do |line, idx|
	lineno = idx + 1

	kanji_kana, _ = line.split(' /', 2)
	kanji, kana = kanji_kana.split(' ', 2)
	kanji = kanji.split(';')
	kana = kana.to_s.strip.delete('[').delete(']').split(';')

	# Theory: If there's no kana, it probably means the kana *is* the kanji.
	kana, kanji = kanji, [] if kana.size.zero?

	# Not going to strip tags out of definitions.
	codes = []
	_.gsub!(/\((#{CODES_REGEXP})\)/) do |m|
		codes << m
		''
	end

	meanings = _.strip

	# NB storing some of these as joined strings instead of arrays so we
	# can use a regular tokenizer instead of the fancy ones
	entry = {
		kanji: kanji.join(" "),
		kana: kana.join(" "),
		codes: codes,
		codes_meanings: CODE_DICTIONARY.values_at(*codes),
		meanings: meanings,
		file_line: line,
		file_lineno: lineno
	}

	send_entry_to_es(entry)

	if lineno % 100 == 0
		puts "#{lineno} records indexed (#{(lineno / lines.size) * 100}%)"
	end
end




