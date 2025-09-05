import os, scipy.io as sci
import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator, TrnasformerMixin
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, balanced_accuracy_score, classification_report, confusion_matrix

sf = 200 #Sample frequency
subjects = range(1,11)
data_path = '/data/interim'

def load_subject_mat(subject):
    file_name = f"S{subject}_E2_processed.mat"
    file_path = os.path.join(data_path, file_name)
    d = sci.loadmat(file_path, squeeze_me = True)
    return d["emg_normalized"].astype(np.float32), d["restimulus"].astype(np.int32), d["rerepetition"].astype(np.int32)

def extract_segments(emg, labels, reps, seg_size = 250): #Window size of 250ms
    trim = sf*seg_size/1000
    segs, start = [], None
    T = len(labels) #Total number of samples
    for i in range(T):
        if labels[i] > 0 and start is None:
            start = (i, labels[i]) #Start of movement
        if start is not None and (labels[i] != start[1] or i == T-1): #Condition to check for end of movement
            s0, lbl = start
            if labels[i] != start[1]:
                end = i
            else:
                end = i+1
            s = s0+trim
            e = max(s+1, end-trim)
        




