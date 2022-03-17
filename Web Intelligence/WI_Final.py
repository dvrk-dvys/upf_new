from tornado import autoreload
import os
import pylab as plt
import nltk
from hSBM_Topicmodel import sbmtm
from bs4 import BeautifulSoup
import numpy
import graphlib
# import graph_tools as gt
from hSBM_Topicmodel.graph_tool import all as gt
from hSBM_Topicmodel.sbmtm import sbmtm



if __name__ == '__main__':
    print()
    path_data = ''

    ## texts
    fname_data = '/hSBM_Topicmodel/corpus.txt'
    filename = os.getcwd() + fname_data

    with open(filename, encoding='utf8') as f:
        x = f.readlines()
    texts = [h.split() for h in x]

    ## titles
    fname_data2 = '/hSBM_Topicmodel/titles.txt'
    filename2 = os.getcwd() + fname_data2

    with open(filename2, 'r', encoding='utf8') as f:
        x = f.readlines()
    titles = [h.split()[0] for h in x]
    i_doc = 0
    print(titles[0])
    print(texts[i_doc][:10])

    ## we create an instance of the sbmtm-class
    model = sbmtm()

    ## we have to create the word-document network from the corpus
    model.make_graph(texts, documents=titles)

    ## we can also skip the previous step by saving/loading a graph
    # model.save_graph(filename = 'graph.xml.gz')
    # model.load_graph(filename = 'graph.xml.gz')

    ## fit the model
    gt.seed_rng(32)  ## seed for graph-tool's random number generator --> same results
    model.fit()
    model.plot(nedges=10000)

