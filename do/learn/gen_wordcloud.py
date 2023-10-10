import sys 
import nltk   
import requests
from bs4 import BeautifulSoup
import numpy as np
import pandas as pd
from os import path
from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator
from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont
from openpyxl import Workbook
import xlsxwriter

#url = "https://www.stata.com/new-in-stata/python-integration/"    
#html = requests.get(url)  
#text = BeautifulSoup(html.text).get_text() 
#print(text)

from sfi import Data 
from sfi import Macro 

wordvar = sys.argv[1]
filevar = sys.argv[2]
freq_path = sys.argv[3]

# this is a list in python 
rawtext = Data.get(wordvar)
text = ' '.join(map(str, rawtext)) #convert list into string 
print(text)

#font_type = ImageFont.load_default()

# font_path="/usr/share/fonts/open-sans/DejaVuSans.ttf"



stop_words = ["IM", "PRETTY", "HIMALPHA", "NO'", "FINANCIAL", "AID", "COLLEGE", "HOMOPHOBIC", "MISOGYNISTIC", "DROP", "TABLE", "RESPONSES", "STUFF", "PREFER", "NOT", "TO", "SAY", "ATTACK", "ASS", "HELICOPTER", "MENTALLY", "ILL", "BULLSHIT", "FUCK", "NIGGER", "KILLER", "5000", "ROCKET", "SHIP", "JEWISH", "STUPID", "SHIT", "LAST", "TITTY", "JEWS", "WOW", "PRIVATE", "RELEVANT", "IDENTIFY", "THING", "DONT", "BELIVE", "GOD", "MEANT", "PUT"]+ list(STOPWORDS)

#from sklearn.feature_extraction.text import CountVectorizer

#instantiate a CountVectorizer object
#cv=CountVectorizer( stop_words=stop_words, ngram_range=(1, 3))



wordcloud = WordCloud(width=1000, height=800, min_font_size=15, stopwords=stop_words, random_state=1, collocations=True, collocation_threshold=10, scale=15, background_color="white").generate(text)

# create a dictionary of word frequencies
text_dictionary = wordcloud.process_text(text)
# sort the dictionary
word_freq={k: v for k, v in sorted(text_dictionary.items(),reverse=True, key=lambda item: item[1])}

#use words_ to print relative word frequencies
rel_freq=wordcloud.words_

# convert sets to lists
word_freq_list = list(word_freq.items())
rel_freq_list = list(rel_freq.items())

#print results
print(word_freq_list)
print(rel_freq_list)

# convert lists to pandas data frames
word_freq_df = pd.DataFrame(word_freq_list, columns=["Word", "Frequency"])

# output dataframes to excel
word_freq_df.to_excel(freq_path, index=False)


from sfi import Platform
import matplotlib
if Platform.isWindows():
    matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

plt.tight_layout(pad=0)
plt.figure( figsize=(30,20) )
plt.tight_layout(pad=0)
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis("off")
plt.savefig(filevar, bbox_inches='tight')