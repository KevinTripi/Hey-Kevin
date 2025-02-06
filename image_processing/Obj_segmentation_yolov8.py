#!/usr/bin/env python
# coding: utf-8

# In[2]:


from ultralytics import YOLO
import cv2
import numpy as np


# Import YOLO segmentation model

# In[3]:


model = YOLO("yolov8m-seg.pt")


# In[4]:


predict = model.predict("/home/kaizen/PycharmProjects/opencv_test/bottle3.jpg", save=True, save_txt=True)




