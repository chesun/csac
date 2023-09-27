// cscript

// need to install package wordcloud
version 17

/* python set exec "/usr/local/bin/python3.6" */

python:
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

#url = "https://www.stata.com/new-in-stata/python-integration/"    
#html = requests.get(url)  
#text = BeautifulSoup(html.text).get_text() 
#print(text)

from sfi import Data 
# this is a list in python 
gender = Data.get("gender_raw_combined")
text = ' '.join(map(str, gender))
print(text)

#font_type = ImageFont.load_default()

# font_path="/usr/share/fonts/open-sans/DejaVuSans.ttf"

stop_words = ["ATTACK", "HELICOPTER", "MENTALLY", "ILL", "BULLSHIT", "NIGGER", "KILLER", "5000", "PREFER", "NOT", "TO", "SAY", "SAY", "STUPID", "SHIT", "LAST"]+ list(STOPWORDS)
wordcloud = WordCloud(width=3000, height=2000, stopwords = stop_words, random_state=1, background_color="black").generate(text)

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
plt.savefig("christina/out/fig/learn/genderwords.png", bbox_inches='tight')

end