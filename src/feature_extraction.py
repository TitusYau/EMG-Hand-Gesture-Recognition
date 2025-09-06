import os, scipy.io as sci
import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, balanced_accuracy_score, classification_report, confusion_matrix

sf = 200 #Sample frequency
subjects = range(1,11)
data_path = 'data/interim'

def load_subject_mat(subject):
    file_name = f"S{subject}_E2_processed.mat"
    file_path = os.path.join(data_path, file_name)
    d = sci.loadmat(file_path, squeeze_me = True)
    emg = d["emg_normalized"].astype(np.float32)
    labels = d["restimulus"].astype(np.float32).ravel() #Squash 1d array
    reps = d["rerepetition"].astype(np.int32).ravel()
    return emg, labels, reps

def extract_segments(emg, labels, reps, seg_size = 250): #Window size of 250ms
    trim = sf*seg_size/1000
    segs, start = [], None
    T = len(labels) #Total number of samples
    for i in range(T):
        if labels[i] > 0 and start is None:
            start = (i, labels[i]) #Start of movement
        if start is not None and (labels[i] != start[1] or i == T-1): #Condition to check for end of movement
            s0, lbl = start #Original index, label set to start
            if labels[i] != start[1]: #End is the first sample where the sample changes, or last sample if the movement continues to the end
                end = i
            else:
                end = i+1
            s = int(s0+trim) #Push the start forward by the trim samples
            e = int(max(s+1, end-trim)) #Pull the end backward, ensure at least one sample remains in the segment
            if e - s >= 0.2*sf: #If the segment is longer than 200ms
                rep = np.bincount(reps[s:e]).argmax() #Count the number of reps within this segment
                segs.append({"EMG":emg[s:e], "labels":lbl, "rep": rep})
            start = None #Reset and move on to next segment
    return segs
        
class OverlapWindowmaker(BaseEstimator, TransformerMixin):
    def __init__(self, sf=200, win_ms=250, stride_ms = 100): #Initialize
        self.sf = sf
        self.win = int(sf*win_ms/1000)
        self.stride = int(sf*stride_ms/1000)
    def fit(self,emg, labels=None):
        return self
    def transform(self,segments):
        emg_window, labels_window, reps_window = [], [], []
        W = self.win
        S = self.stride
        for seg in segments:
            emg_seg, labels_seg, reps_seg = seg["EMG"], seg["labels"], seg["rep"]
            T = len(emg_seg)
            for s in range(0, max(0, T-W)+1, S):
                emg_window.append(emg_seg[s:s+W])
                labels_window.append(labels_seg)
                reps_window.append(reps_seg)
        return np.asarray(emg_window), np.asarray(labels_window), np.asarray(reps_window)


#Feature extraction (Time-domain features per channel per window)
def td_features(emg_window):
    def features(x):
        mav = np.mean(np.abs(x), axis=0) #Mean absolute value - muscle activity
        wl = np.sum(np.abs(np.diff(x,axis=0)), axis=0) #Waveform length- Complexity/Variability of signal
        var = np.var(x,axis=0) #Variance - fluctuation of the emg signal
        rms = np.sqrt(np.mean(x**2, axis=0)) #Measure of signal effective value - intensity of muscle contractions
        return np.concatenate([mav,wl,var,rms])
    return np.vstack([features(x) for x in emg_window]).astype(np.float32)

class Featureizer(BaseEstimator, TransformerMixin):
    def fit(self, emg, labels = None):
        return self
    def transform(self, emg_window):
        return td_features(emg_window)

#Per subject evaluation
subjects = range(1,11)
results = []
for subj in subjects:
    emg, labels, rep = load_subject_mat(subj)
    segs = extract_segments(emg, labels, rep, seg_size=250)

    # 250 ms window, 100 ms stride => 60% overlap at 200 Hz
    win = OverlapWindowmaker(sf=200, win_ms=250, stride_ms=100)
    emg_w, labels_w, rep_w = win.transform(segs)

    # Split by repetition to avoid leakage
    train = np.isin(rep_w, [1,3,4,6]); val = (rep_w==2); test = (rep_w==5)

    feat = Featureizer()
    emg_tr, emg_va, emg_te = feat.transform(emg_w[train]), feat.transform(emg_w[val]), feat.transform(emg_w[test])
    labels_tr, labels_va, labels_te = labels_w[train], labels_w[val], labels_w[test]

    pipe = Pipeline([
        ("scaler", StandardScaler()),
        ("clf", SVC(kernel="rbf", C=10, gamma="scale", class_weight="balanced"))
    ])
    pipe.fit(emg_tr, labels_tr)

    labels_pred = pipe.predict(emg_te)
    acc  = accuracy_score(labels_te, labels_pred)
    bacc = balanced_accuracy_score(labels_te, labels_pred)
    print(f"Subject {subj}: acc={acc:.3f} bacc={bacc:.3f}")

    # Validation monitoring
    labels_pred_val = pipe.predict(emg_va)
    print(f"  Val acc={accuracy_score(labels_va, labels_pred_val):.3f} bacc={balanced_accuracy_score(labels_va, labels_pred_val):.3f}")

    results.append({"subject": subj, "acc": acc, "bacc": bacc})

# Aggregate
df = pd.DataFrame(results)
print(df.describe())

